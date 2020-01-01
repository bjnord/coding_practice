# Day 22: Slam Shuffle

## Part One

There isn't much to do while you wait for the droids to repair your ship. At least you're drifting in the right direction. You decide to practice a new [card shuffle](https://en.wikipedia.org/wiki/Shuffling) you've been working on.

Digging through the ship's storage, you find a deck of **space cards**! Just like any deck of space cards, there are 10007 cards in the deck numbered `0` through `10006`. The deck must be new - they're still in **factory order**, with `0` on the top, then `1`, then `2`, and so on, all the way through to `10006` on the bottom.

You've been practicing three different **techniques** that you use while shuffling. Suppose you have a deck of only 10 cards (numbered `0` through `9`):

**To `deal into new stack`**, create a new stack of cards by dealing the top card of the deck onto the top of the new stack repeatedly until you run out of cards:

```
Top          Bottom
0 1 2 3 4 5 6 7 8 9   Your deck
                      New stack

  1 2 3 4 5 6 7 8 9   Your deck
                  0   New stack

    2 3 4 5 6 7 8 9   Your deck
                1 0   New stack

      3 4 5 6 7 8 9   Your deck
              2 1 0   New stack

Several steps later...

                  9   Your deck
  8 7 6 5 4 3 2 1 0   New stack

                      Your deck
9 8 7 6 5 4 3 2 1 0   New stack

```

Finally, pick up the new stack you've just created and use it as the deck for the next technique.

**To `cut N` cards**, take the top `N` cards off the top of the deck and move them as a single unit to the bottom of the deck, retaining their order. For example, to `cut 3`:

```
Top          Bottom
0 1 2 3 4 5 6 7 8 9   Your deck

      3 4 5 6 7 8 9   Your deck
0 1 2                 Cut cards

3 4 5 6 7 8 9         Your deck
              0 1 2   Cut cards

3 4 5 6 7 8 9 0 1 2   Your deck

```

You've also been getting pretty good at a version of this technique where `N` is negative! In that case, cut (the absolute value of) `N` cards from the bottom of the deck onto the top. For example, to `cut -4`:

```
Top          Bottom
0 1 2 3 4 5 6 7 8 9   Your deck

0 1 2 3 4 5           Your deck
            6 7 8 9   Cut cards

        0 1 2 3 4 5   Your deck
6 7 8 9               Cut cards

6 7 8 9 0 1 2 3 4 5   Your deck

```

**To `deal with increment N`**, start by clearing enough space on your table to lay out all of the cards individually in a long line. Deal the top card into the leftmost position. Then, move `N` positions to the right and deal the next card there. If you would move into a position past the end of the space on your table, wrap around and keep counting from the leftmost card again. Continue this process until you run out of cards.

For example, to `deal with increment 3`:

```

0 1 2 3 4 5 6 7 8 9   Your deck
. . . . . . . . . .   Space on table
^                     Current position

Deal the top card to the current position:

  1 2 3 4 5 6 7 8 9   Your deck
0 . . . . . . . . .   Space on table
^                     Current position

Move the current position right 3:

  1 2 3 4 5 6 7 8 9   Your deck
0 . . . . . . . . .   Space on table
      ^               Current position

Deal the top card:

    2 3 4 5 6 7 8 9   Your deck
0 . . 1 . . . . . .   Space on table
      ^               Current position

Move right 3 and deal:

      3 4 5 6 7 8 9   Your deck
0 . . 1 . . 2 . . .   Space on table
            ^         Current position

Move right 3 and deal:

        4 5 6 7 8 9   Your deck
0 . . 1 . . 2 . . 3   Space on table
                  ^   Current position

Move right 3, wrapping around, and deal:

          5 6 7 8 9   Your deck
0 . 4 1 . . 2 . . 3   Space on table
    ^                 Current position

And so on:

0 7 4 1 8 5 2 9 6 3   Space on table

```

Positions on the table which already contain cards are still counted; they're not skipped. Of course, this technique is carefully designed so it will never put two cards in the same position or leave a position empty.

Finally, collect the cards on the table so that the leftmost card ends up at the top of your deck, the card to its right ends up just below the top card, and so on, until the rightmost card ends up at the bottom of the deck.

The complete shuffle process (your puzzle input) consists of applying many of these techniques. Here are some examples that combine techniques; they all start with a **factory order** deck of 10 cards:

```
deal with increment 7
deal into new stack
deal into new stack
Result: 0 3 6 9 2 5 8 1 4 7

```

```
cut 6
deal with increment 7
deal into new stack
Result: 3 0 7 4 1 8 5 2 9 6

```

```
deal with increment 7
deal with increment 9
cut -2
Result: 6 3 0 7 4 1 8 5 2 9

```

```
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
Result: 9 2 5 8 1 4 7 0 3 6

```

Positions within the deck count from `0` at the top, then `1` for the card immediately below the top card, and so on to the bottom. (That is, cards start in the position matching their number.)

After shuffling your **factory order** deck of 10007 cards, **what is the position of card `2019`?**

## Part Two

After a while, you realize your shuffling skill won't improve much more with merely a single deck of cards. You ask every 3D printer on the ship to make you some more cards while you check on the ship repairs. While reviewing the work the droids have finished so far, you think you see [Halley's Comet](https://en.wikipedia.org/wiki/Halley%27s_Comet) fly past!

When you get back, you discover that the 3D printers have combined their power to create for you a single, giant, brand new, **factory order** deck of **`119315717514047` space cards**.

Finally, a deck of cards worthy of shuffling!

You decide to apply your complete shuffle process (your puzzle input) to the deck **`101741582076661` times in a row**.

You'll need to be careful, though - one wrong move with this many cards and you might **overflow** your entire ship!

After shuffling your new, giant, **factory order** deck that many times, **what number is on the card that ends up in position `2020`?**

### Part Two Pre-Design Thoughts

Subtitle: "Sometimes Your Own Thinking Doesn't Get You Far Enough"

\[BJN: Here's as far as I got before I needed help:]

Clearly we need to optimize how our cards are stored and accessed, so that each of our three techniques is really fast.

- The "deal into new stack" technique simply reverses the cards, so we could keep an "is deck reversed?" flag, and access a card using position `nCards - n`.
- The "cut N cards" technique simply rotates the cards, so we could keep a "top card position" index, and access a card using position `n + topCardPosition`. This needs to work modulo-style (but not using the modulo operator, which will be too slow).
- The "deal with increment N" technique is the one I'm not sure how to optimize, other than replacing the modulo operator with "compare-and-add/-subtract N" for speed. If we keep the same algorithm (where we make a new array), this needs to reset the "is deck reversed?" flag and the "top card position" index.

The thing is, these techniques have to work in combination, and the order will matter. It might not be enough to keep a simple deck state; do we need a stack of operations à la [RPN](https://en.wikipedia.org/wiki/Reverse_Polish_notation)?

As I mulled this further I realized:

- We don't need a generalized solution for a deck of huge-N cards. We only care about the one card at position P when everything is done.
- (Inspired by thoughts of RPN and stacks:) We could run the techniques **backwards** so the final "card at position P" condition would have been "card at position Q" one step prior, etc.
- Since (1) we're only tracking "card at position P", and (2) `cardAt(P) === P` for a factory-order deck, and (3) we're not altering the deck, just the position of interest: We don't actually need an array.
- There's no way we can do 101741582076661 of **anything** in a reasonable amount of time.

When implementing the "shuffle N times" method, I noticed something interesting about puzzle example #4: It comes back to the initial state after 4 rounds:

```
[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
[ 9, 2, 5, 8, 1, 4, 7, 0, 3, 6 ]
[ 6, 5, 4, 3, 2, 1, 0, 9, 8, 7 ]
[ 7, 4, 1, 8, 5, 2, 9, 6, 3, 0 ]
[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
...
```

I noticed also that card 0 appears in positions 0, 7, 6, and 9… and those 4 values appear in columns 0, 7, 6, and 9 (in various orders). The same thing is going on with values 1, 4, 5, and 2 -- and with values 3 and 8. Hmmm… I wonder if that example was a hint?

\[BJN: …so I implemented the "one card of interest" class, and got really close to figuring out how to make the "deal with increment N" modulo go backwards… but I ran the machinery just 100x and even that took way too long. Time to look at the subreddit for help!]

### Part Two Design

#### metalim's solution

Reddit user [metalim](https://www.reddit.com/user/metalim)
posted [this](https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbwauzi/)

[Python](https://github.com/metalim/metalim.adventofcode.2019.python/blob/master/22_cards_shuffle.ipynb)

Second part is just composition of linear polynomials `ax+b mod L`, where `L` is length of the deck.

First, convert all shuffling rules into linear polynomial. Remember to compose in reverse order. "deal into new stack" is just negative position. "cut" just adds to `b`. And "deal with increment" multiplies both `a` and `b` by `modinv`, effectively dividing them, modulo `L`. `modinv(x,n) == pow(x,n-2,n)` for prime `n` is everything you need to remember.

Second, raise polynomial to the number of steps, mod `L`. Didn't use the formula, just did it recursively, because we practice programming here, right? Similar to `modpow`, it takes `O(log N)` time (which you hardly notice for numbers with less than million digits).

Third, calculate initial position (and hence - card number) using resulting polynomial.

All 3 steps take less than a millisecond.

#### sasajuric's Solution

\[BJN: This was the clearest explanation… they figured out the math enough to explain it to someone else, which is better than I could have done! So I started here.]

Reddit user [sasajuric](https://www.reddit.com/user/sasajuric)
posted [this](https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbvcnfr/)

After failing miserably at doing it on my own, I spent a lot of time reading through the comments in this thread. However, I still had a hard time figuring out the exact math details. Finally, it dawned on me that I could just defer calculating remainders to the later stage, and this reduced the need to do `modinv`, or rely on other fancy principles.

The other relevant insight was that `a*x+b` can be normalized to `rem(a, deck_size) * x + rem(b, deck_size)`, which keeps integers reasonably sized. Coupling that with general directions taken from this thread (representing shuffle as a function, exponentiation by squaring), I was able to finish it. Thank you all for your explanations!

My solution in Elixir is [here](https://github.com/sasa1977/aoc/blob/master/lib/2019/201922.ex). I've included an expanded explanation of my approach in the code docs.

\[BJN: Their Elixir code is really elegant! Here are some excerpts of comments and code:]

##### Linear transformations

Given such representation, we can express each transformation as a linear function that takes the initial position
as its argument and returns the new position:

- deal into new stack: `new_pos = -current_pos + deck_size - 1`
- cut: `new_pos = current_pos - cut_pos`
- deal with increment: `new_pos = increment * current_pos`

\[BJN: The functions in their Elixir code show the `a` and `b` for all 3 cases:]

```
defp function("deal into new stack", deck_size), do: {-1, deck_size - 1}
defp function("cut " <> position, _deck_size), do: {1, -String.to_integer(position)}
defp function("deal with increment " <> step, _deck_size), do: {String.to_integer(step), 0}
```

Note that these functions can return positions which are not in the range `0..(deck_size - 1)`, but we can easily
normalize the resulting positions with `rem(pos, deck_size)` for zero and positive positions, or
`deck_size - rem(-pos, deck_size)` for negative positions.

Notice that all of the listed functions are linear, i.e. they can be represented as `a*x + b`.
This means that the entire shuffle sequence can be expressed as a single function which is a composition of
all the steps.

\[BJN: That's the **first key insight**: The three shuffle operations are linear expressions, and can easily be combined into a single function. I feel I deserve credit for being on the right track (see "stack of operations" above), but my math is too weak to have quite put it all together.]

For example, suppose that we have only three steps in the sequence, called `f`, `g`, `h`. Then the entire transformation
can be represented as `f(g(h(current_pos)))`. We can build this composition iteratively by composing `g` and `h`, and then
composing `f` with the result. Given two functions `f = a*x+b` and `g = c*x+d`, composition `g(f(x))` is `c*a*x + c*b + d`.

\[BJN: …and this (the formula for composing two of them) I would not have gotten. Here's their Elixir code for that; `normalize` is just modulo that handles negatives properly:]

```
defp compose({ga, gb}, {fa, fb}, deck_size),
  do: {normalize(ga * fa, deck_size), normalize(ga * fb + gb, deck_size)}
```

This is all we need to solve part 1. We read the input, and build a collection of `{a, b}` pairs which represent
each step as a function. Then we build a composition of these steps to produce the function which represents the
entire transformation. Finally, we apply the function by simply calculating `a*2019+b` to get the new
position of 2019 after the entire shuffle has been performed. Remember that we need to normalize the result
to fall in the range of `0..(deck_size - 1)`.

##### Inverting the direction

Another challenge of part 2 is that we have to find the value that ends up in position 2020. However, our function
works in the opposite direction - it computes the new position from the previous one. To solve this, we need
to inverse the shuffle function.

An inverse of a linear function `a*x + b` is `1/a - b/a` (obtained by swapping `x` and `y` in the original function
definition, and transforming to standard representation). To make sure we don't end up with floats,
we need to increase `1` and `b` (by repeatedly adding `deck_size`) to make sure the inverse function
coefficients are still integers.

\[BJN: Their beautiful Elixir code for this part:]

```
defp inverse({a, b}, deck_size),
  do: {normalized_div(1, a, deck_size), normalized_div(-b, a, deck_size)}

defp normalized_div(a, b, deck_size) do
  a
  |> Stream.iterate(&(&1 + deck_size))
  |> Enum.find(&(rem(&1, b) == 0))
  |> div(b)
  |> normalize(deck_size)
end
```

\[BJN: So again, I can take credit for realizing I'd need to run the shuffle operations in reverse for Part Two, but that "inverse of a linear function" bit completely stumped me when I tried to do a pencil-and-paper analysis. See, kids? Math is valuable!]

##### Applying the function many times

To apply the function n times, we can simply compose it with it self. A shuffle applied 4 times is `f(f(f(f(x))))`.
Unfortunately, the number of steps is quite large (101,741,582,076,661), so this won't finish in a reasonable
amount of time. To speed things up, we can use the technique called [exponentiation by squaring](https://en.wikipedia.org/wiki/Exponentiation_by_squaring).

For example to produce the function which performs the shuffle sequence 100 times, we can do the following:

```
1. f2(x) = f(f(x))
2. f4(x) = f2(f2(x))
3. f8(x) = f4(f4(x))
4. f16(x) = f8(f8(x))
5. f32(x) = f16(f16(x))
6. f64(x) = f32(f32(x))
7. f100(x) = f64(f32(f4(x)))
```

So instead of performing 100 compositions, we only did 7. For 101,741,582,076,661 steps we'll only need about
100 compositions, which can be done quickly.

\[BJN: And that's the **second key insight**: When computing linear expressions, there's a much faster way to compute it N times. If I ever learned this technique, I've long since forgotten it.]
