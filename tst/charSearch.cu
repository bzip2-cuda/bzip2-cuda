#include <iostream>

using namespace std;

__global__ void fnSearch(char *str, char *key, int *res)
{
	*res = -1;
	if(str[threadIdx.x] == *key)
		*res = threadIdx.x;
}

int main(int argc, char *argv[])
{
	if (argc != 3)
	{
		cout << "Usage: charSearch.out STRING KEY" << endl;
		exit(1);
	}

	char *dStr, *dKey;
	int *dRes, *hRes;
	cudaMalloc((void**)&dStr, sizeof(char) * strlen(argv[1]));
	cudaMalloc((void**)&dKey, sizeof(char));
	cudaMalloc((void**)&dRes, sizeof(int));
	hRes = new(int);
	
	cudaMemcpy(dStr, argv[1], sizeof(char) * strlen(argv[1]), cudaMemcpyHostToDevice);
	cudaMemcpy(dKey, argv[2], sizeof(char), cudaMemcpyHostToDevice);
	
	fnSearch<<<1, strlen(argv[1])>>>(dStr, dKey, dRes);
	
	cudaMemcpy(hRes, dRes, sizeof(int), cudaMemcpyDeviceToHost);
	
	cout << "Result: " << *hRes << endl;
	
	return 0;
}
