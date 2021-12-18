#!/bin/sh
#
# a little utility to help build test cases
if [ "$1" = "-n" ]; then
	shift
	DRYRUN=1
else
	DRYRUN=0
fi
if [ ! -f "$1" ]; then
	echo "tokenize.sh: file not found: $1" >&2
	exit 66
fi
if [ $DRYRUN -eq 1 ]; then
	perl -pe 'if (/TOKENIZE/) { s/,/:s, /g; s/\[/:o, /g; s/\]/:c, /g; s/(\d)/$1, /g; }' "$1" | diff "$1" -
else
	perl -pe 'if (/TOKENIZE/) { s/,/:s, /g; s/\[/:o, /g; s/\]/:c, /g; s/(\d)/$1, /g; }' -i "$1"
fi
