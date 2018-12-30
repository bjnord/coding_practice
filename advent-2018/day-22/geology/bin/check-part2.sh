#!/bin/sh
make examples run | grep 'Part 2.*fewest minutes to target'
( fmt -168 ../README.md; cat lib/geology.ex Makefile ) | egrep --color '\*\*45\*\*|1010'
