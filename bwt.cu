#include <stdio.h>
#include <stdlib.h>

//#include "bitonic_kernel.cu"

#define NUM    5

__device__ inline void swap(int & a, int & b)
{
	// Alternative swap doesn't use a temporary register:
	// a ^= b;
	// b ^= a;
	// a ^= b;
	
    int tmp = a;
    a = b;
    b = tmp;
}

__global__ static void bitonicSort(int * values)
{
    extern __shared__ int shared[];

    const int tid = threadIdx.x;

    // Copy input to shared mem.
    shared[tid] = values[tid];

    __syncthreads();

    // Parallel bitonic sort.
    for (int k = 2; k <= NUM; k *= 2)
    {
        // Bitonic merge:
        for (int j = k / 2; j>0; j /= 2)
        {
            int ixj = tid ^ j;
            
            if (ixj > tid)
            {
                if ((tid & k) == 0)
                {
                    if (shared[tid] > shared[ixj])
                    {
                        //swap(shared[tid], shared[ixj]);
                        int tmp = shared[tid];
    					shared[tid] = shared[ixj];
					    shared[ixj] = tmp;
                    }
                }
                else
                {
                    if (shared[tid] < shared[ixj])
                    {
                        //swap(shared[tid], shared[ixj]);
                        int tmp = shared[tid];
    					shared[tid] = shared[ixj];
					    shared[ixj] = tmp;
                    }
                }
            }
            
            __syncthreads();
        }
    }
    
    // Write result.
    values[tid] = shared[tid];
    
//    values[tid] = 0;
}


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
        values[i] = NUM - i;
    }
    
    output(values, NUM);

    int * dvalues;
    cudaMalloc((void**)&dvalues, sizeof(int) * NUM);
    cudaMemcpy(dvalues, values, sizeof(int) * NUM, cudaMemcpyHostToDevice);

    bitonicSort<<<1, NUM, sizeof(int) * NUM>>>(dvalues);

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
