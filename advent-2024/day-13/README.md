# Day 13: Claw Contraption

## Part One

Next up: the [lobby](../../advent-2020/day-24)
of a resort on a tropical island. The Historians take a moment to admire
the hexagonal floor tiles before spreading out.

Fortunately, it looks like the resort has a new
[arcade](https://en.wikipedia.org/wiki/Amusement_arcade)! Maybe you can
win some prizes from the
[claw machines](https://en.wikipedia.org/wiki/Claw_machine)?

The claw machines here are a little unusual. Instead of a joystick or
directional buttons to control the claw, these machines have two buttons
labeled `A` and `B`. Worse, you can't just put in a token and play; it
costs **3 tokens** to push the `A` button and **1 token** to push the `B`
button.

With a little experimentation, you figure out that each machine's
buttons are configured to move the claw a specific amount to the **right**
(along the `X` axis) and a specific amount **forward** (along the `Y`
axis) each time that button is pressed.

Each machine contains one **prize**; to win the prize, the claw must be
positioned **exactly** above the prize on both the `X` and `Y` axes.

You wonder: what is the smallest number of tokens you would have to
spend to win as many prizes as possible? You assemble a list of every
machine's button behavior and prize location (your puzzle input). For
example:

```
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400

    Button A: X+26, Y+66
    Button B: X+67, Y+21
    Prize: X=12748, Y=12176

    Button A: X+17, Y+86
    Button B: X+84, Y+37
    Prize: X=7870, Y=6450

    Button A: X+69, Y+23
    Button B: X+27, Y+71
    Prize: X=18641, Y=10279
```

This list describes the button configuration and prize location of four
different claw machines.

For now, consider just the first claw machine in the list:

-   Pushing the machine's `A` button would move the claw `94` units
    along the `X` axis and `34` units along the `Y` axis.
-   Pushing the `B` button would move the claw `22` units along the `X`
    axis and `67` units along the `Y` axis.
-   The prize is located at `X=8400`, `Y=5400`; this means that from the
    claw's initial position, it would need to move exactly `8400` units
    along the `X` axis and exactly `5400` units along the `Y` axis to be
    perfectly aligned with the prize in this machine.

The cheapest way to win the prize is by pushing the `A` button `80`
times and the `B` button `40` times. This would line up the claw along
the `X` axis (because `80*94 + 40*22 = 8400`) and along the `Y` axis
(because `80*34 + 40*67 = 5400`). Doing this would cost `80*3` tokens
for the `A` presses and `40*1` for the `B` presses, a total of `280`
tokens.

For the second and fourth claw machines, there is no combination of A
and B presses that will ever win a prize.

For the third claw machine, the cheapest way to win the prize is by
pushing the `A` button `38` times and the `B` button `86` times. Doing
this would cost a total of `200` tokens.

So, the most prizes you could possibly win is two; the minimum tokens
you would have to spend to win all (two) prizes is `480`.

You estimate that each button would need to be pressed **no more than
`100` times** to win a prize. How else would someone be expected to play?

Figure out how to win as many prizes as possible. **What is the fewest
tokens you would have to spend to win all possible prizes?**

### Part One Design

> **Spoilers ahead!**

**FINALLY** a math-related AoC day that I know how to solve without help!
Usually higher math is my frenemy in AoC. This may be a first in 7 years.

Two words: Linear. Algebra.

I was the despair of my math professors in college, but even in high
school, one thing I did get pretty solidly was solving a system of N
equations in N variables. Rewrite the 2nd equation in terms of the 2nd
variable, substitute into the 1st equation, solve, and then substitute
back into the original 2nd equation.

Showing my work:

```
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

equation 1: a * 34 + b * 67 = 5400
equation 2: a * 94 + b * 22 = 8400

a * 94 + b * 22 = 8400
b * 22 = 8400 - a * 94
b = (8400 - a * 94) / 22

a * 34 + ((8400 - a * 94) / 22) * 67 = 5400
a * ay + ((px - a * ax) / bx) * by = py

b = (8400 - a * 94) / 22
b = (px - a * ax) / bx
```

## Part Two

As you go to win the first prize, you discover that the claw is nowhere
near where you expected it would be. Due to a unit conversion error in
your measurements, the position of every prize is actually
`10000000000000` higher on both the `X` and `Y` axis!

Add `10000000000000` to the `X` and `Y` position of every prize. After
making this change, the example above would now look like this:

```
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=10000000008400, Y=10000000005400

    Button A: X+26, Y+66
    Button B: X+67, Y+21
    Prize: X=10000000012748, Y=10000000012176

    Button A: X+17, Y+86
    Button B: X+84, Y+37
    Prize: X=10000000007870, Y=10000000006450

    Button A: X+69, Y+23
    Button B: X+27, Y+71
    Prize: X=10000000018641, Y=10000000010279
```

Now, it is only possible to win a prize on the second and fourth claw
machines. Unfortunately, it will take **many more than `100` presses** to
do so.

Using the corrected prize coordinates, figure out how to win as many
prizes as possible. **What is the fewest tokens you would have to spend
to win all possible prizes?**

### Part Two Design

> **Spoilers ahead!**

...and another thing we did a lot of in my comp sci program was matrices.
Turning a system of N equations in N variables, into a matrix (tensor),
and doing the dot product to solve, is still pretty familiar ground.

I have been eager to start learning [Nx](https://hexdocs.pm/nx/Nx.html)
ever since I first saw José Valim demonstrate its power a few years ago.
This was a perfect opportunity.

Alternative strategies:

- [Cramer's rule](https://en.wikipedia.org/wiki/Cramer%27s_rule):
    discussion [here](https://www.reddit.com/r/adventofcode/comments/1hd7irq/comment/m1tyftz/);
    apparently it's pretty inefficient for the general case, but fine for
    the 2x2 in this puzzle
- [Gaussian elimination](https://en.wikipedia.org/wiki/Gaussian_elimination)
