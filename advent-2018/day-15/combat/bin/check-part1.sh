#!/bin/sh
make examples | egrep '(Outcome|Elf power)'
( fmt -168 ../README.md; cat lib/combat.ex Makefile ) | egrep --color '27730|36334|39514|27755|28944|18740|13400|13987|18468|250594'
