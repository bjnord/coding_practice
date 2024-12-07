# Day 7: Bridge Repair

## Part One

The Historians take you to a familiar
[rope bridge](../../advent-2022/day-09) over a
river in the middle of a jungle. The Chief isn't on this side of the
bridge, though; maybe he's on the other side?

When you go to cross the bridge, you notice a group of engineers trying
to repair it. (Apparently, it breaks pretty frequently.) You won't be
able to cross until it's fixed.

You ask how long it'll take; the engineers tell you that it only needs
final calibrations, but some young elephants were playing nearby and
**stole all the operators** from their calibration equations! They could
finish the calibrations if only someone could determine which test
values could possibly be produced by placing any combination of
operators into their calibration equations (your puzzle input).

For example:

```
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
```

Each line represents a single equation. The test value appears before
the colon on each line; it is your job to determine whether the
remaining numbers can be combined with operators to produce the test
value.

Operators are **always evaluated left-to-right**, **not** according to
precedence rules. Furthermore, numbers in the equations cannot be
rearranged. Glancing into the jungle, you can see elephants holding two
different types of operators: **add** (`+`) and **multiply** (`*`).

Only three of the above equations can be made true by inserting
operators:

-   `190: 10 19` has only one position that accepts an operator: between
    `10` and `19`. Choosing `+` would give `29`, but choosing `*` would
    give the test value (`10 * 19 = 190`).
-   `3267: 81 40 27` has two positions for operators. Of the four
    possible configurations of the operators, **two** cause the right side
    to match the test value: `81 + 40 * 27` and `81 * 40 + 27` both
    equal `3267` (when evaluated left-to-right)!
-   `292: 11 6 16 20` can be solved in exactly one way:
    `11 + 6 * 16 + 20`.

The engineers just need the **total calibration result**, which is the sum
of the test values from just the equations that could possibly be true.
In the above example, the sum of the test values for the three equations
listed above is `3749`.

Determine which equations could possibly be true. **What is their total
calibration result?**

### Part One Design

> **Spoilers ahead!**

I decided to just brute force part one. While I was pretty sure that part
two was going to add operators... the only optimization I could think of
was pruning branches that had already accumulated more than the expected
total, and that would be worthless if the new operators were `-` or `/` etc.

(Side note: I spent too much time figuring out how to flatten the list of
equation operator combinations. It was good Elixir practice but ultimately
code I didn't need. It's in the common module as `History.flatten_2d/1`.)

Brute force was fast enough for part 1. And then...

## Part Two

The engineers seem concerned; the total calibration result you gave them
is nowhere close to being within safety tolerances. Just then, you spot
your mistake: some well-hidden elephants are holding a **third type of
operator**.

The [concatenation](https://en.wikipedia.org/wiki/Concatenation)
operator (`||`) combines the digits from its left and right inputs into
a single number. For example, `12 || 345` would become `12345`. All
operators are still evaluated left-to-right.

Now, apart from the three equations that could be made true using only
addition and multiplication, the above example has three more equations
that can be made true by inserting operators:

-   `156: 15 6` can be made true through a single concatenation:
    `15 || 6 = 156`.
-   `7290: 6 8 6 15` can be made true using `6 * 8 || 6 * 15`.
-   `192: 17 8 14` can be made true using `17 || 8 + 14`.

Adding up all six test values (the three that could be made before using
only `+` and `*` plus the new three that can now be made by also using
`||`) produces the new **total calibration result** of `11387`.

Using your new knowledge of elephant hiding spots, determine which
equations could possibly be true. **What is their total calibration
result?**

### Part Two Design

> **Spoilers ahead!**

...we ended up with three operators, none of which decrease the accumulated
value. (With one notable exception that I didn't think of immediately.)
Brute force still worked, but it took over a minute to run both parts.

Welp. Time for a better implementation with pruning, and that got the time
down to 2.75s — I haven't used
[Benchee](https://github.com/bencheeorg/benchee)
before but I really like it. Easy to set up and good documentation. The
improvement on one equation (3 operators):

```
Operating System: Linux
CPU Information: AMD EPYC 7571
Number of Available Cores: 4
Available memory: 15.45 GB
Elixir 1.16.0
Erlang 26.2.1
JIT enabled: true

Name                     ips        average  deviation         median         99th %
dynamic               231.92        4.31 ms    ±11.34%        4.18 ms        6.00 ms
dynamic_bigger        227.08        4.40 ms     ±8.99%        4.38 ms        5.99 ms
dynamic_big           214.43        4.66 ms    ±21.41%        4.40 ms        9.23 ms
op_atoms                1.05      953.80 ms    ±10.50%      968.21 ms     1101.84 ms

Comparison:
dynamic               231.92
dynamic_bigger        227.08 - 1.02x slower +0.0919 ms
dynamic_big           214.43 - 1.08x slower +0.35 ms
op_atoms                1.05 - 221.21x slower +949.49 ms
```

I wondered if changing the order of the operators would matter significantly,
and Benchee reveals that it doesn't. I have a few more ideas for further
optimization, but this is probably good enough for now.
