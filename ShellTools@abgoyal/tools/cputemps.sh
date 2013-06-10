#! /bin/bash

t=($(sensors | grep Core | awk '{print $3}'))

for i in ${t[@]}
do
	echo -n ${i/+/} " "
done
echo

