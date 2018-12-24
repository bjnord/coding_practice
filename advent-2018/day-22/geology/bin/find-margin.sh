#!/bin/sh -e
make geology
m=45
while [ "$m" -gt 0 ]; do
	echo "==> margin=$m <=="
	time ./geology --parts=2 --margin-x=$m input/input.txt
	m=`expr $m + 1`
	echo ""
done
