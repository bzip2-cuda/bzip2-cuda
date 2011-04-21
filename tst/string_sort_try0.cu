//Taken from http://ldn.linuxfoundation.org/article/c-gpu-and-thrust-strings-gpu
//Also, https://groups.google.com/group/thrust-users/msg/0eac80d2e41cbcfb?pli=1, https://groups.google.com/group/thrust-users/browse_thread/thread/f4b1b825cc927df9?pli=1, 

#include <thrust/device_ptr.h>
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <thrust/copy.h>

#include <cstring>
#include <vector>
#include <iterator>

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

int main()
{
	char* all_repeats_h = "abcb\0bcba\0cbab\0babc";
	int max_width = 4;

	vector <std::string> h_vec;

	for (int i = 0; i < max_width; i++) //rotation
	{
		h_vec.push_back(all_repeats_h + i*(max_width+1)*sizeof(char));
	}

	std::cout << "Content of h_vec..\n";
	for(int i = 0; i<h_vec.size(); i++)
	{
		std::cout << h_vec[i] << endl;
	}

	thrust::device_vector<device_string> d_vec;
	d_vec.reserve(h_vec.size());

	for(vector<std::string>::iterator iter = h_vec.begin(); iter!=h_vec.end(); ++iter)
	{
		device_string d_str(*iter);
		d_vec.push_back(d_str);
	}

	thrust::sort(d_vec.begin(), d_vec.end() ); //sort

	std::cout << " Done with sort().. \nThe sorted list of conjugates are: \n\n";

	for(int i = 0; i < d_vec.size(); i++)
	{
		device_string d_str(d_vec[i]);
		h_vec[i] = d_str;
		std::cout << h_vec[i] <<endl;
	}
	return 0;
}
