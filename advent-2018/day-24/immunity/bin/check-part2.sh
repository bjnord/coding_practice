#!/bin/sh
make examples run | grep 'Part 2.*Immune System units'
( fmt -168 ../README.md; cat lib/*.ex Makefile ) | egrep --color '\*51|106[^0-9]'
