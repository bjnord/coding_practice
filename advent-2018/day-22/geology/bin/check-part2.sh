#!/bin/sh
make examples run | grep 'Part 2.*fewest minutes'
( fmt -168 ../README.md; cat lib/geology.ex Makefile ) | egrep --color '[^0-9]45|1022'
