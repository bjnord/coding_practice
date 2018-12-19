#!/bin/sh
perl -pe 's/\|/\e[31m\|\e[0m/g; s/\~/\e[34m\~\e[0m/g; s/\./ /g;' "$@" | less -R
