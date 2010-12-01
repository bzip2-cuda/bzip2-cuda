#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/device_ptr.h>
#include <thrust/copy.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include <thrust/fill.h>

#include <cstdio>
#include <iostream>
#include <cstring>
#include <iterator>

#define POOL_SZ (10*1024*1024)

using namespace std;

////////////////////DEVICE_STRING STARTS
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
	__host__ static void init()
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
	__host__ static void fin()
	{
		init();
		thrust::device_free(pool_cstr);
	}

	// Parametrized constructor to copy one device_string to another.
	__host__ device_string( const device_string& s )
	{
		cstr_len = s.cstr_len;
		raw = s.raw;
		cstr = s.cstr;
	}

	// Parametrized constructor to copy a std::string to device_string type
	__host__ device_string( const std::string& s )
	{
		cstr_len = s.length();
		init();
		cstr = pool_top;
		pool_top += cstr_len+1;
		raw = (char *) raw_pointer_cast(cstr);
		cudaMemcpy( raw, s.c_str(), cstr_len+1, cudaMemcpyHostToDevice );
	}

	// Default constructor.
	__host__ __device__ device_string()
	{
		cstr_len = -1;
		raw = NULL;
	}

	// Conversion operator to copy device_string type to std::string
	// This is where the problem is

	__host__ operator std::string(void)
	{
		std::string ret;
		//device_ptr<char*>::iterator it = cstr.begin();
		thrust::copy(cstr, cstr+cstr_len, back_inserter(ret));
		return ret;
	}
};

char* device_string::pool_raw;
thrust::device_ptr<char> device_string::pool_cstr;
thrust::device_ptr<char> device_string::pool_top;

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
////////////////////DEVICE_STRING ENDS

void rotate(int N, char *word, vector<string> h_vec)
{
	char *str, *rot;
	cudaMalloc((void**)&str, sizeof(char) * (N + 1));
	cudaMalloc((void**)&rot, sizeof(char) * ((N + 1) * (N + 1)));
		
	thrust::device_ptr<char> strD(str);
	thrust::device_ptr<char> rotD(rot);
	thrust::copy(word, word + N, strD);
	
	for (int i = 0; i < N; i++)	//Rotations happen in this loop
	{
		thrust::copy(strD + i, strD + N, rotD + (i * N));
		thrust::copy(strD, strD + i, rotD + (i * N) + (N - i));
	}
	
	for (int i = 0; i < N; i++)	//We extract data back from the GPU
	{
		cudaMemcpy(word, rot + (i * N), N, cudaMemcpyDeviceToHost);
		h_vec.push_back(word);
	}
	
	cudaFree(str);
	cudaFree(rot);
}

void sort(vector<string> h_vec, char *result)
{
	thrust::device_vector<device_string> d_vec;
	d_vec.reserve(h_vec.size());

	for(vector<std::string>::iterator iter = h_vec.begin(); iter!=h_vec.end(); ++iter)
	{
		device_string d_str(*iter);
		d_vec.push_back(d_str);
	}

	thrust::sort(d_vec.begin(), d_vec.end() );
	
	for(int i = 0; i < d_vec.size(); i++)
	{
		device_string d_str(d_vec[i]);
		h_vec[i] = d_str;
		//cout << h_vec[i] <<endl;
		result[i] = h_vec[i][h_vec[i].length()-1];
	}
}

void bwt( char *word)
{
	int N = strlen(word);
	vector<string> h_vec;
	char *result = new char(N);

	rotate(N, word, h_vec);
	
	sort(h_vec, result);	
	
	cout << result << endl;
}

int main(int argc, char *argv[])
{	
	if (argc != 2)
	{
		cout << "Usage: bwt_thrust STRING_INPUT" << endl;
		exit(1);
	}

	char *word = new(char);	
	strcpy(word, argv[1]);
	bwt(word);
	
	return 0;
}
