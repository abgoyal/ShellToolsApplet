#! /bin/bash


while (( $# ))
do
	echo -n $1
	df -B GB $2 | tail -n 1 | awk '{ printf ":%s  ", $4 }'
	shift
	shift
done
echo

