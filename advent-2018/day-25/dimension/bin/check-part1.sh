#!/bin/sh
make examples run | grep 'Part 1.*number of constellations'
( fmt -168 ../README.md; cat lib/*.ex Makefile ) | egrep --color '\*\*[12348]\*\*|338'
