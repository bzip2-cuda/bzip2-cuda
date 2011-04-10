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

void clgeneration()
{
	//Initialisation
	thrust::device_vector<char> d_list(256);
	thrust::sequence(d_list.begin(), d_list.begin() + 256);
	thrust::device_vector<int> d_freq(256);
//	thrust::sort_by_key(d_freq.begin(), d_freq.end(), d_list);
	thrust::device_vector<int> d_leader(256);
	thrust::device_vector<int> cl(256);
	thrust::fill(d_leader.begin(), d_leader.end(), -1);
	thrust::fill(cl.begin(), cl.end(), 0);
	thrust::device_vector<int> front = cl.begin();
	thrust::device_vector<int> rear = cl.begin();
	thrust::device_vector<int> curr = cl.begin();

	//New iNode
	thrust::device_vector<int> mid(4);
	thrust::device_vector<int> MinFreq;
	thrust::fill(mid.begin(), mid.end(), 500);
	if (curr ≤ 255)
		mid [0] = d_freq[curr+1];
	if (curr ≤ 254)
		mid [1] = d_freq[curr+2];
	if (rear > front)
		mid [2] = d_freq[front+1];
	if (rear > front + 1)
		mid [3] = d_freq[front+2];
	MinFreq = mid[0] + mid[1];
	d_freq[rear + 1] = MinFreq;
	d_leader[rear + 1] = -1;
	if (isLeaf (mid[0]))
		leader[curr+1] = rear + 1;
		cl[curr+1] = cl[curr + 1] + 1;
		curr = curr + 1;
	else
		leader[front + 1] = rear + 1;
		front = front + 1;
	if (isLeaf(mid[1]))
		leader[curr + 1] = rear + 1;
		cl[curr+1] = cl[curr + 1] + 1;
		curr = curr + 1;
	else
		leader[front + 1] = rear + 1;

//Select Module
Forall processors Pi (lNodesCur < i ≤ n)
	if (d_freq[i] ≤ MinFreq)
		Copy[i – lNodesCur].freq ← lNodes[i].freq
		Copy[i – lNodesCur].index ← i
		Copy[i – lNodesCur].isLeaf ← true
		if (i = n || lNodes[i+1].freq > MinFreq)
			CurLeavesNum ← i – lNodesCur

//Updating iterators
P1 Sets
	mergeRear ← iNodesRear
	mergeFront ← iNodesFront
	if((CurLeavesNum+ iNodesRear - iNodesFront)%2=0)
		iNodesFront ← iNodesRear
	else if ((iNodesRear - iNodesFront != 0) &&
	(F[lNodesCur+CurLeavesNum]≤iNodes[iNodesRear].freq))
		mergeRear--
		iNodesFront ← iNodesRear - 1
	else
		iNodesFront ← iNodesRear
		CurLeavesNum --
	lNodesCur ← lNodesCur + CurLeavesNum iNodesRear++

//Meld Module
Forall processors Pi (1 ≤ i ≤ TempLength) do in parallel
	ind ← iNodesRear + i
	iNodes [ind].freq ← temp [2*i-1].freq + temp [2*i].freq
	iNodes[ind].leader ← -1
	if (temp [2*i-1].isleaf)
		lNodes [temp [2*i – 1].index].leader ← ind
		CL[temp [2*i – 1].index]++
	else
		iNodes [temp [2*i – 1].index].leader ← ind
	if (temp [2*i].isleaf)
		lNodes [temp [2*i].index].leader ← ind
		CL[temp [2*i ].index]++
	else
		iNodes [temp [2*i].index].leader ← ind
P1 sets
	iNodesRear ← iNodesRear + (TempLength/2)


//Updating leaders
Forall processors Pi (1 ≤ i ≤ n) do in parallel
	if (lNodes[i].leader != -1)
		if (iNodes[lNodes[i].leader].leader != -1)
			lNodes[i].leader ← iNodes[lNodes[i].leader].leader
			CL[i] ++
}

int main()
{
	clgeneration();
	return 0;
}
