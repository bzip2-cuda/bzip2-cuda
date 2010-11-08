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
#include <thrust/copy.h>
#include <thrust/sequence.h>

#include <iostream>

#define N 10
#define ARGC_EXPECTED_VAL 2

int main(int argc, char *argv[])
{
	if (argc != ARGC_EXPECTED_VAL)
	{
		std::cout << "Usage: sort_thrust <string to be sorted>\n";
		return 1;
	}
	thrust::device_vector<char> keyD(N, ' ');			//Size N, initialized with ' 's
	thrust::host_vector<char> keyH = argv[1];			//The string to be sorted is taken from the command line
	thrust::copy(keyH.begin(), keyH.end(), keyD.begin());		//Copy the contents of keyH to keyD

	thrust::device_vector<int> valueD(N, 0);			//Size N, filled with 0s
	thrust::sequence(valueD.begin(), valueD.end());			//set valueD's values to a sequence from 0 to N-1
//	thrust::host_vector<int> valueH(valueD.begin(), valueD.end());
	thrust::stable_sort_by_key(keyD.begin(), keyD.end(), valueD);

	//ANIRUDH IS CONFUSED FROM HERE ON

	return 0;
}
