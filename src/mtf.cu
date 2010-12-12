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

void mtf()
{
	thrust::host_vector<char> h_vec(256);
	thrust::generate(h_vec.begin(), h_vec.end(), thrust::sequence(0, 255));
}

int main(int argc, char *argv[])
{
	mtf();
	return 0;
}
