#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/device_ptr.h>
#include <thrust/copy.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include <thrust/find.h>

#include <cstdio>
#include <iostream>
#include <cstring>

using namespace std;

__global__ void fnSearch(char *str, char *key, int *res)
{
	*res = -1;
	if(str[threadIdx.x] == *key)
		*res = threadIdx.x;
}

void mtf(char* word)
{
	//Parallel initialisation of character set	
	thrust::device_vector<char> d_list(256);
	thrust::sequence(d_list.begin(), d_list.begin() + 256);
	thrust::host_vector<char> list(256);
	thrust::device_vector<char> d_word(strlen(word));
	thrust::device_vector<int> dRes;
	int counter, index;
	d_word = word;
//	cudaMemcpy(d_word, word, sizeof(char) *strlen(word), cudaMemcpyHostToDevice);

	for (counter = 0; counter < word.length(); counter++)
	{
		//Scan for character on cpu
		
		fnSearch<<<1, 256>>>(d_list, d_word[counter], dRes);
/*		thrust::copy(d_list.begin(), d_list.end(), list.begin());
		for (index = 0; ; index++)
		{
			if (word[counter] == list[index])
				break;
		}
*/
		//Shifting of the character set in parallel
		thrust::device_vector<char> temp(256);
		thrust::copy(d_list.begin(), d_list.begin() + index - 1, temp.begin());
		thrust::copy(temp.begin(), temp.begin() + index - 1, d_list.begin() + 1);

//		thrust::copy(d_list.begin(), d_list.end(), list.begin());
		d_list[0] = d_word[counter];
//		d_list = list;
	}
	for (counter = 0; counter <= word.length(); counter++)
	{
		char ch = list[counter];		
		cout << counter << "\t" << ch << endl;
	}
}

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		cout << "Usage: mtf.out STRING_INPUT" << endl;
		exit(1);
	}

	char* word = new char(strlen(argv[1]);
	word = argv[1];
	mtf(word);
	return 0;
}
