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

        $ ./machine --disassemble input-day-21/input.txt | grep -1 R0
        x00001B JMPI x7
        x00001C EQRR R5 R0 R2
        x00001D JADR R2 R4

1. So we need to know the value of R5, the first time `IP=x00001C` is executed:

        $ ./machine --parts=5 --show-reg input-day-21/input.txt | grep -4 ':x00001C' | head
        [...]
                                                                          R4=x00001C
               x00001C EQRR R5 R0 R2
        IP(R4):x00001D    R0=x000000  R1=x000001  R2=x000000  R3=x000001  R4=-------  R5=x0315E1
        [...]

1. Voilà! Starting the program with `R0=x0315E1` (202209) makes the program exit, so that's the answer.
