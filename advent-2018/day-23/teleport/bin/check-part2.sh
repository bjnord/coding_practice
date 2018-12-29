#!/bin/sh
make examples run | grep 'Part 2.*distance to closest point' | grep ' [^ ]*$'
( fmt -168 ../README.md; cat lib/*.ex Makefile ) | egrep --color '\*\*36\*\*|101599540'
