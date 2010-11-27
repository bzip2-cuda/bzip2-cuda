#ifndef STRING_SORT_CU
#define STRING_SORT_CU

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

using namespace std;

class device_string
{
public:
	int cstr_len;
	char* raw;
	thrust::device_ptr<char> cstr;

	static char* pool_raw;
	static thrust::device_ptr<char> pool_cstr;
	static thrust::device_ptr<char> pool_top;

	// Sets the variables up the first time its used.
	__host__ static void init();
	
	// Destructor for device variables used.
	__host__ static void fin();

	// Parametrized constructor to copy one device_string to another.
	__host__ device_string( const device_string& s );

	// Parametrized constructor to copy a std::string to device_string type
	__host__ device_string( const std::string& s );

	// Default constructor.
	__host__ __device__ device_string();

	// Conversion operator to copy device_string type to std::string
	// This is where the problem is
	__host__ operator std::string(void);
};

char* device_string::pool_raw;
thrust::device_ptr<char> device_string::pool_cstr;
thrust::device_ptr<char> device_string::pool_top;

bool __device__ operator< (device_string lhs, device_string rhs);

#endif
