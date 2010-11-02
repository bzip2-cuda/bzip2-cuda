#include <iostream>
#include <vector>
#include <algorithm>
#include <cassert>
using namespace std; 
__global__ void fnKern(float *pA, float *pB, float *pSum) 
{ pSum[threadIdx.x] = pA[threadIdx.x] + pB[threadIdx.x]; } 
int main() 
{ int N = 512; 
int SIZE = N * sizeof(float); 
vector <float> a(N), b(N), sum(N); 
fill(a.begin(), a.end(), 100.123); 
fill(b.begin(), b.end(), 200.123); 
float *pA, *pB, *pSum; 
cudaMalloc((void**)&pA, SIZE); 
cudaMalloc((void**)&pB, SIZE); 
cudaMalloc((void**)&pSum, SIZE); 
cudaMemcpy(pA, &*a.begin(), SIZE, cudaMemcpyHostToDevice); 
cudaMemcpy(pB, &*b.begin(), SIZE, cudaMemcpyHostToDevice); 
fnKern<<<1, N>>>(pA, pB, pSum); 
cudaMemcpy(&*sum.begin(), pSum, SIZE, cudaMemcpyDeviceToHost); 
for(int i = 1 ; i < N; ++i) 
{ if(sum[i] != sum[0]) 
{ cout << i << "->" << sum[i] << endl; 
return 0; } 
} 
cout << "Sum : " << sum[0] << endl; 
return 0; 
}
