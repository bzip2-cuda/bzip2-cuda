#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/device_ptr.h>
#include <thrust/copy.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include <thrust/fill.h>

#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <cstring>

int main(int argc, char *argv[])
{
	char *word = new(char);
	std::cin >> word;
	int N = strlen(word) - 1;
	int i;

	char *str, *rot;
	
	cudaMalloc((void**)&str, sizeof(char) * (N + 1));
	cudaMalloc((void**)&rot, sizeof(char) * ((N + 1) * (N + 1)));
	
	thrust::device_ptr<char> strD(str);
//	thrust::device_ptr<device_string> rotD(rot);
	thrust::device_ptr<char> rotD(rot);
	
	thrust::copy(word, word + N, strD);

	for (i = 0; i < N; i++)				//Rotations
	{						//Check indices. 90% wrong. :P
		thrust::copy(strD + i, strD + N, rotD + (i * N));
		thrust::copy(strD, strD + i, rotD + (i * N) + (N - i));
	}
	
	//How to sort strings?
	thrust::sort(rotD, rotD + N);

	for (i = 0; i < N; i++)
	{
		cudaMemcpy(word, rot + (i * N), N, cudaMemcpyDeviceToHost);
		std::cout << word <<std::endl;
	}
	
	cudaFree(str);
	cudaFree(rot);
	
	return 0;
}
