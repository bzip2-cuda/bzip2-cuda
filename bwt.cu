#include <stdio.h>
#include <stdlib.h>

#include "bitonic_kernel.cu"

void output(int val[], int n)
{
	printf("%s", "Output:\n");

	for (int i = 0; i < n; i++)
	{
		printf("%d\t", val[i]);
	}
	printf("%s", "\n");
}

int main(int argc, char** argv)
{

	int values[NUM];

	for(int i = 0; i < NUM; i++)
	{
		values[i] = rand();
		//values[i] = NUM - i -1;
	}

	output(values, NUM);

	int * dvalues;
	cudaMalloc((void**)&dvalues, sizeof(int) * NUM);
	cudaMemcpy(dvalues, values, sizeof(int) * NUM, cudaMemcpyHostToDevice);

	bitonicSort<<<1, NUM, sizeof(int) * NUM>>>(dvalues);
	
	////
	cudaError_t ERR;
	ERR = cudaGetLastError();
	printf("Status: %s\n", cudaGetErrorString (ERR));
	////
	
	cudaMemcpy(values, dvalues, sizeof(int) * NUM, cudaMemcpyDeviceToHost);

	cudaFree(dvalues);

	output(values, NUM);

	bool passed = true;
	for(int i = 1; i < NUM; i++)
	{
		if (values[i-1] > values[i])
		{
			passed = false;
		}
	}

	printf( "Test %s\n", passed ? "PASSED" : "FAILED");

	return 0;
}
