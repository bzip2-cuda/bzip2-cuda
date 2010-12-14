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

#define POOL_SZ (10*1024*1024)

using namespace std;

void mtf(string word)
{
	//Parallel initialisation of character set	
	thrust::device_vector<char> d_list(256);
	thrust::sequence(d_list.begin(), d_list.begin() + 256);
	thrust::host_vector<char> list(256);

	int counter, index;
	for (counter = 0; counter < word.length(); counter++)
	{
		//Scan for character on cpu
		thrust::copy(d_list.begin(), d_list.end(), list.begin());
		for (index = 0; ; index++)
		{
			if (word[counter] == list[index])
				break;
		}
		//Shifting of the character set in parallel
		thrust::device_vector<char> temp(256);
		thrust::copy(d_list.begin(), d_list.begin() + index - 1, temp.begin());
		thrust::copy(temp.begin(), temp.begin() + index - 1, d_list.begin() + 1);
/*		for ( ; index != 0; index--)
		{	
			list[index] = list[index-1];
		}*/
		thrust::copy(d_list.begin(), d_list.end(), list.begin());
		list[0] = word[counter];
		d_list = list;
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

	string word;
	word = argv[1];
	mtf(word);
	return 0;
}
