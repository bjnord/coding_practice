#!/bin/sh
# player 1 cards [2, 3, 5]
# player 2 cards [7, 11]
# expr ( ( ( ( ( 1 * 2 + 1 ) * 3 + 2 ) * 5 + 3 ) * 1202 + 81518 ) * 7 + 1 ) * 11 + 2
t1=`expr 1 \* 2 + 1`
t2=`expr $t1 \* 3 + 2`
t3=`expr $t2 \* 5 + 3`
echo "player 1 hash is $t3 (expect 58)"
t4=`expr $t3 \* 1202 + 81518`
echo "separator hash is $t4 (expect 151234)"
t5=`expr $t4 \* 7 + 1`
t6=`expr $t5 \* 11 + 2`
echo "full hash is $t6 (expect 11645031)"
