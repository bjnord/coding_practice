#!/bin/sh
make examples run | grep 'Part 1.*winning army units'
( fmt -168 ../README.md; cat lib/*.ex Makefile ) | egrep --color '5216|26937'
