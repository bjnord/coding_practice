#!/bin/sh
make examples run | grep 'Part 1.*resource value'
( fmt -168 ../README.md; cat lib/*.ex Makefile ) | egrep --color '1147|603098'
