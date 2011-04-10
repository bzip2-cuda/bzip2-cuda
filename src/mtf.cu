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
#include <vector>

using namespace std;

__global__ void fnSearch(char *str, char *key, int *res)
{
	*res = -1;
	if(str[threadIdx.x] == *key)
		*res = threadIdx.x;
}

void mtf(vector<char> word)
{
	//Parallel initialisation of character set	
	thrust::device_vector<char> d_list(256);
	thrust::sequence(d_list.begin(), d_list.begin() + 256);
	thrust::host_vector<char> list(256);
	thrust::device_vector<char> d_word(word.size());
	thrust::device_vector<int> dRes;
	int counter;
	thrust::device_vector<char>::iterator iter;
	thrust::host_vector<char> h_word(word.size());
	char ch;
/*	h_word = word;
	d_word = h_word;
	h_word = d_word;
*/	thrust::copy(word.begin(), word.end(), d_word.begin());
	thrust::device_vector<char> temp(256);
	for (counter = 0; counter < word.size(); counter++)
	{
		//Scan for character on cpu
		iter = thrust::find(d_list.begin(), d_list.end(), d_word[counter]);

		//Shifting of the character set in parallel		
		thrust::copy(d_list.begin(), iter - 1, temp.begin());
		thrust::copy(temp.begin(), iter - 1, d_list.begin() + 1);

		d_list[0] = d_word[counter];
		thrust::copy(d_list.begin(), d_list.end(), list.begin());
	}
	for (counter = 0; counter <= word.size(); counter++)
	{
		ch = list[counter];		
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

	int len = strlen(argv[1]);
	char *arg = new char(len);
	strcpy(arg, argv[1]);
	vector<char> word(arg, arg + sizeof(arg));
	/*while ( *(arg) != '\0' )
	{
		word.push_back(*(arg++));
	}*/
	mtf(word);
	return 0;
}
