//Taken from https://groups.google.com/group/thrust-users/msg/0eac80d2e41cbcfb?pli=1, https://groups.google.com/group/thrust-users/browse_thread/thread/f4b1b825cc927df9?pli=1, http://ldn.linuxfoundation.org/article/c-gpu-and-thrust-strings-gpu

//Our thanks to Shashank Srikant

#include <cstring>
#include <string>
#include <vector>
#include <iterator>

#include <thrust/device_ptr.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <thrust/copy.h>

#define POOL_SZ (10*1024*1024)

#include "string_sort.h"

using namespace std;

// Sets the variables up the first time its used.
__host__ static void device_string::init()
{
	static bool v = true;
	if( v )
	{
		v = false;

		pool_cstr = thrust::device_malloc(POOL_SZ);
		pool_raw  = (char*)raw_pointer_cast( pool_cstr );
		pool_top = pool_cstr;
	}
}
// Destructor for device variables used.
__host__ static void device_string::fin()
{
	init();
	thrust::device_free(pool_cstr);
}

// Parametrized constructor to copy one device_string to another.
__host__ device_string::device_string( const device_string& s )
{
	cstr_len = s.cstr_len;
	raw = s.raw;
	cstr = s.cstr;
}

// Parametrized constructor to copy a std::string to device_string type
__host__ device_string::device_string( const std::string& s )
{
	cstr_len = s.length();
	init();
	cstr = pool_top;
	pool_top += cstr_len+1;
	raw = (char *) raw_pointer_cast(cstr);
	cudaMemcpy( raw, s.c_str(), cstr_len+1, cudaMemcpyHostToDevice );
}

// Default constructor.
__host__ __device__ device_string::device_string()
{
	cstr_len = -1;
	raw = NULL;
}

// Conversion operator to copy device_string type to std::string
// This is where the problem is

__host__ device_string::operator device_string::std::string(void)
{
	std::string ret;
	//device_ptr<char*>::iterator it = cstr.begin();
	thrust::copy(cstr, cstr+cstr_len, back_inserter(ret));
	return ret;
}

// User-defined comparison operator
bool __device__ operator< (device_string lhs, device_string rhs)
{
	char *l = lhs.raw;
	char *r = rhs.raw;

	for( ; *l && *r && *l==*r; )
	{
	++l;
	++r;
	}
	return *l < *r;
}
