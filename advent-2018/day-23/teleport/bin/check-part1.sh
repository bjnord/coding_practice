#!/bin/sh
make examples run | grep 'Part 1.*nanobots in range'
( fmt -168 ../README.md; cat lib/*.ex Makefile ) | egrep --color '\*\*7\*\*|613'
