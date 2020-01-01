# Day 21: Chronal Conversion

## Part 1

You should have been watching where you were going, because as you wander the new North Pole base, you trip and fall into a very deep hole!

Just kidding. You're falling through time again.

If you keep up your current pace, you should have resolved all of the temporal anomalies by the next time the device activates. Since you have very little interest in browsing history in 500-year increments for the rest of your life, you need to find a way to get back to your present time.

After a little research, you discover two important facts about the behavior of the device:

First, you discover that the device is hard-wired to always send you back in time in 500-year increments. Changing this is probably not feasible.

Second, you discover the **activation system** (your puzzle input) for the time travel module. Currently, it appears to **run forever without halting**.

If you can cause the activation system to **halt** at a specific moment, maybe you can make the device send you so far back in time that you cause an [integer underflow](https://cwe.mitre.org/data/definitions/191.html) **in time itself** and wrap around back to your current time!

The device executes the program as specified in [manual section one](https://adventofcode.com/2018/day/16) and [manual section two](https://adventofcode.com/2018/day/19).

Your goal is to figure out how the program works and cause it to halt. You can only control **register 0**; every other register begins at 0 as usual.

Because time travel is a dangerous activity, the activation system begins with a few instructions which verify that **bitwise AND** (via `bani`) does a **numeric** operation and **not** an operation as if the inputs were interpreted as strings. If the test fails, it enters an infinite loop re-running the test instead of allowing the program to execute normally. If the test passes, the program continues, and assumes that **all other bitwise operations** (`banr`, `bori`, and `borr`) also interpret their inputs as **numbers**. (Clearly, the Elves who wrote this system were worried that someone might introduce a bug while trying to emulate this system with a scripting language.)

**What is the lowest non-negative integer value for register 0 that causes the program to halt after executing the fewest instructions?** (Executing the same instruction multiple times counts as multiple instructions executed.)

### Part 1 Solution

I wrote a disassembler while working on day 19, and did that pay off in spades!

1. Since the activation system is concerned with the bitwise operations, it was time to add a hexadecimal output option. (Should have done that to begin with!)

1. Now, if all we can control is R0, the first question is: How is R0 used in the activation system? The answer is, only one place, as a comparison before a jump:

        $ ./gadget --disassemble input-day-21/input.txt | grep -1 R0
        x00001B JMPI x7
        x00001C EQRR R5 R0 R2
        x00001D JADR R2 R4

1. So we need to know the value of R5, the first time `IP=x00001C` is executed:

        $ ./gadget --parts=1 --show-reg input-day-21/input.txt | grep -4 ':x00001C' | head
        [...]
                                                                          R4=x00001C
               x00001C EQRR R5 R0 R2
        IP(R4):x00001D    R0=x000000  R1=x000001  R2=x000000  R3=x000001  R4=-------  R5=x0315E1
        [...]

1. Voilà! Starting the program with `R0=x0315E1` (202209) makes the program exit, so that's the answer.

## Part 2

In order to determine the timing window for your underflow exploit, you also need an upper bound:

**What is the lowest non-negative integer value for register 0 that causes the program to halt after executing the most instructions?** (The program must actually halt; running forever does not count as halting.)

### Part 2 Design

> **Spoilers ahead!**

After disassembling and decompiling and fiddling with optimizing the C code and trying to figure out what the "activation system" program does (see `src/gadget-optimized.c`)... it finally occurred to me that I don't need to know what it does. It's a big add/multiply/shift state machine that produces a new big value from 0x000000-0xFFFFFF each time through.

All that matters is figuring out when the first value repeats, because at that point it'll cycle forever. The value before the repetition will be the maximum times you can go through the loop without entering the infinite cycle. So:

        $ cc -o gadget-optimized src/gadget-optimized.c
        $ ./gadget-optimized 2>r5-values.out
        $ bin/repeat.pl r5-values.out
        repeated r[5]=0xD01AE1
        $ grep -1 -n 0xD01AE1 r5-values.out | head -7
        6174-r[5]=0xD13DB9
        6175:r[5]=0xD01AE1    <-- 0xD01AE1 seen for the first time
        6176-r[5]=0x0A288E
        --
        11992-r[5]=0xB3B61C   <-- 0xB3B61C = last value before repeat
        11993:r[5]=0xD01AE1   <-- 0xD01AE1 repeats
        11994-r[5]=0x0A288E
        $ grep -1 -n 0xB3B61C r5-values.out | head -3
        11991-r[5]=0x8EC2B5
        11992:r[5]=0xB3B61C   <-- ...and it is not seen before loop 11992
        11993-r[5]=0xD01AE1

Starting the program with `R0=xB3B61C` (11777564) does reach a halt state.

### Part 2 Optimization

The Elf code machine, unfortunately, churns away on the Day 21 `input.txt` for longer than I'm willing to wait. I brought my optimization of the inner loop back to the Elf code... this required adding instructions for binary shift-right (`brsr` and `brsi`) and subtraction (`subr` and `subi`) to the CPU. The resulting `input-fast.txt` completes almost immediately.
