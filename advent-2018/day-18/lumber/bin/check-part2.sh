#!/bin/sh
make examples run | grep 'Part 2.*resource value'
( fmt -168 ../README.md; cat lib/*.ex Makefile ) | egrep --color 'zero|210000'
