#!/bin/sh
make examples run | grep 'Part 1.*risk level'
( fmt -168 ../README.md; cat lib/geology.ex Makefile ) | egrep --color '114|10395'
