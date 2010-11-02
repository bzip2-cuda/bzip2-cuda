#include <stdio.h>
# include "cutil.h"

__global__ void fnKern(int *pA, int *pB, int *pSum)
{
    pSum[threadIdx.x] = pA[threadIdx.x] + pB[threadIdx.x];
}

int main()
{
    const int N = 512;
    int SIZE = N * sizeof(float);
    int a[N], b[N], sum[N], aa[N], bb[N];

    for (int i = 0; i < N; i++)
    {
    	a[i] = b[i] = 100;
    	//sum[i] = 0;
    }
    
    printf("A: %d\nB: %d\n", a[0], b[0]);

    int *pA, *pB, *pSum;
    CUDA_SAFE_CALL(cudaMalloc((void**)&pA, SIZE));
    CUDA_SAFE_CALL(cudaMalloc((void**)&pB, SIZE));
    CUDA_SAFE_CALL(cudaMalloc((void**)&pSum, SIZE));

    CUDA_SAFE_CALL(cudaMemcpy(pA, a, SIZE, cudaMemcpyHostToDevice));
    CUDA_SAFE_CALL(cudaMemcpy(pB, b, SIZE, cudaMemcpyHostToDevice));
    //cudaMemcpy(pSum, sum, SIZE, cudaMemcpyHostToDevice);

    fnKern<<<1, N>>>(pA, pB, pSum);
    CUT_CHECK_ERROR("fnKern failed");

    CUDA_SAFE_CALL(cudaMemcpy(aa, pA, SIZE, cudaMemcpyDeviceToHost));
    CUDA_SAFE_CALL(cudaMemcpy(bb, pB, SIZE, cudaMemcpyDeviceToHost));
    CUDA_SAFE_CALL(cudaMemcpy(sum, pSum, SIZE, cudaMemcpyDeviceToHost));

    printf("A: %d\nB: %d\nSum: %d\n", aa[0], bb[0], sum[0]);
    return 0;
}
