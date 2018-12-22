#!/bin/sh
PARTS="--parts=1"
if [ "$1" = -21 ]; then
	PARTS="--parts=12"
	shift
fi
if [ "$1" = -r -o "$1" = --run ]; then
	RUN=true
	shift
fi
if [ "$1" = -21 ]; then
	PARTS="--parts=12"
	shift
fi
if [ -z "$1" ]; then
	FILE=input/input.txt
else
	FILE="$1"
	shift
fi
if [ ! -r "$FILE" ]; then
	echo "$0: can't read $FILE" >&2
	exit 1
fi
BASE="`basename $FILE .txt`"
make machine && \
	./machine --decompile $INITIAL $NUMERIC $FILE >$BASE.c && \
	./machine --disassemble $INITIAL $NUMERIC $FILE >$BASE.asm && \

# for the screen
tail -20 $BASE.c
tail $BASE.asm
echo "==> $FILE <=="
head -3 $FILE
echo "[...]"
tail $FILE

# for analysis
expand $BASE.c >/tmp/do-c$$
(echo;echo;echo;echo;echo;echo;echo;cat $BASE.asm) | pr -m -t -w 200 /tmp/do-c$$ - >parallel-$BASE.out
rm -f /tmp/do-c$$

if [ "$RUN" = true ]; then
	cc $BASE.c && \
		./machine $PARTS $INITIAL $NUMERIC --show-reg $FILE && \
		./a.out
fi
