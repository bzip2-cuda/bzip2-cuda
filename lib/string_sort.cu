#ifndef STRING_SORT_CU
#include <thrust/device_vector.h>
#include <thrust/device_ptr.h>
#include <thrust/sort.h>

/*
#ifndef STRING_SORT_HEADER
#define STRING_SORT_HEADER
#endif
*/

//Taken from http://ldn.linuxfoundation.org/article/c-gpu-and-thrust-strings-gpu

class device_string
{
	public:
	int cstr_len;
	char* raw;
	thrust::device_ptr cstr;

	static char* pool_raw;
	static thrust::device_ptr pool_cstr;
	static thrust::device_ptr pool_top;

	__host__ static void init()
	{
		static bool v = true;
		if( v )
		{
			v = false;

			const int POOL_SZ = 10*1024*1024;

			pool_cstr = thrust::device_malloc(POOL_SZ);
			pool_raw  = raw_pointer_cast( pool_cstr );
			pool_top = pool_cstr;
		}
	}
	__host__ static void fini()
	{
		init();
		thrust::device_free(pool_cstr);
	}

	__host__ device_string( const device_string& s )
	{
		cstr_len = s.cstr_len;
		raw = s.raw;
		cstr = s.cstr;
	}

	__host__ device_string( const std::string& s ) : cstr_len( s.length() )
	{
		init();

		cstr = pool_top;
		pool_top += cstr_len+1;
		raw = raw_pointer_cast( cstr );

		cudaMemcpy( raw, s.c_str(), cstr_len+1, cudaMemcpyHostToDevice );
	}
	__host__ __device__ device_string() : cstr_len( -1 ), raw( 0 )
	{}

	__host__ operator std::string ()
	{
	std::string ret;
	thrust::copy( cstr, cstr+cstr_len, back_inserter(ret));
	return ret;
	}
};


char* device_string::pool_raw;
thrust::device_ptr device_string::pool_cstr;
thrust::device_ptr device_string::pool_top;

#endif
