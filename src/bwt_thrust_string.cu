/*
Pseudocode:
char string;
char key -> string;
int value -> index; -> send to gpu to assign values 0-blah
thrust::stable_sort_by_key();
get sorted value
send to gpu -> sorted value, string
return string[value[tid]-1]
*/

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/device_ptr.h>
#include <thrust/copy.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include <thrust/fill.h>

#include<cuda.h>

#include <stdio.h>
#include <iostream>
#include <cstring>

#define ARGC_EXPECTED_VAL 2

__global__ void fnKern(char *key, int *val, char *str)
{
	str[threadIdx.x] = key[val[threadIdx.x] - 1];
}

int main(int argc, char *argv[])
{
	/*if (argc != ARGC_EXPECTED_VAL)
	{
		std::cout << "Usage: sort_thrust <string to be sorted>\n";
		return 1;
	}*/
	char *word = new(char);
	std::cin >> word;
	int N = strlen(word);

	char *strH = new(char);	
	int *value = NULL;
	value = new int[N];
	
	strH[0] = word[0];
	value[0] = 0;
	for (int i = 1; i < N; i++)
	{
		strH[i] = word[N - i];
		value[i] = N - i;
	}

	char *key, *str;
	int *val;
	
	cudaMalloc((void**)&key, sizeof(char) * N);
	cudaMalloc((void**)&val, sizeof(int) * N);
	cudaMalloc((void**)&str, sizeof(char) * N);

	thrust::device_ptr<char> keyD(key);	
	thrust::device_ptr<char> strD(str);
	thrust::device_ptr<int> valD(val);
	
	thrust::copy(strH, strH + N, keyD);

	thrust::copy(value, value + N, valD);
	
	thrust::stable_sort_by_key(keyD, keyD + N, valD);
	
//	fnKern<<<1, N>>>(key, val, str);
	
	cudaMemcpy(strH, key, N, cudaMemcpyDeviceToHost);
	cudaMemcpy(value, val, N, cudaMemcpyDeviceToHost);
//	strH = thrust::raw_pointer_cast(strD);	
	std::cout <<strH << std::endl;
	for (int i = 0; i < N; i++)
	std::cout << value[i] << std::endl;

	cudaFree(key);
	cudaFree(str);
	cudaFree(val);
	
	return 0;
}
