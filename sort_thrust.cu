char string;
char key -> string;
int value -> index; -> send to gpu to assign values 0-blah
thrust::stable_sort_by_key();
get sorted value
send to gpu -> sorted value, string
return string[value[tid]-1]
