#ifndef BWT_CU
#define BWT_CU
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
#include <time.h>

#include "../lib/device_string.cu"

#define POOL_SZ (10*1024*1024)

using namespace std;

void rotate(int N, char *word, vector<string> *h_vec)
{
	char *str, *rot;
	cudaMalloc((void**)&str, /*sizeof(char) * */(N + 1));
	cudaMalloc((void**)&rot, /*sizeof(char) * */((N + 1) * (N + 1)));
		
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
		h_vec->push_back(word);
	}
	
	cudaFree(str);
	cudaFree(rot);
}

void sort(vector<string> *h_vec, char *result)
{
	thrust::device_vector<device_string> d_vec;
	d_vec.reserve(h_vec->size());

	for(vector<std::string>::iterator iter = h_vec->begin(); iter!=h_vec->end(); ++iter)
	{
		device_string d_str(*iter);
		d_vec.push_back(d_str);
	}

	thrust::sort(d_vec.begin(), d_vec.end() );
	
	for(int i = 0; i < d_vec.size(); i++)
	{
		device_string d_str(d_vec[i]);
		h_vec->at(i) = d_str;
		result[i] = (h_vec->at(i)).at(h_vec->at(i).length() - 1);
	}
}

void bwt( char *word)
{
	int N = strlen(word);

	vector<string> h_vec;

	rotate(N, word, &h_vec);

	char *result = new char(N);	
	sort(&h_vec, result);
//	return result;
}

int main(int argc, char *argv[])
{	
	if (argc != 2)
	{
		cout << "Usage: bwt.out STRING_INPUT" << endl;
		exit(1);
	}

//	char word[256];
//	strcpy(word, argv[1]);
	int N = strlen(argv[1]);
	
	struct timespec t0, t1;
	struct timespec *pt0, *pt1;
	pt0 = &t0;
	pt1 = &t1;
	
	clock_gettime(0, pt0);
	bwt(argv[1]);
	clock_gettime(0, pt1);
	
	cout << t1.tv_nsec - t0.tv_nsec << endl;
//	cout << result << endl;
	
	return 0;
}

#endif
