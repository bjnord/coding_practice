# Day 21: Dirac Dice

## Part One

There's not much to do as you slowly descend to the bottom of the ocean.
The submarine computer challenges you to a nice game of **Dirac Dice**.

This game consists of a single
[die](https://en.wikipedia.org/wiki/Dice), two
[pawns](https://en.wikipedia.org/wiki/Glossary_of_board_games#piece),
and a game board with a circular track containing ten spaces marked `1`
through `10` clockwise. Each player's **starting space** is chosen
randomly (your puzzle input). Player 1 goes first.

Players take turns moving. On each player's turn, the player rolls the
die **three times** and adds up the results. Then, the player moves their
pawn that many times **forward** around the track (that is, moving
clockwise on spaces in order of increasing value, wrapping back around
to `1` after `10`). So, if a player is on space `7` and they roll `2`,
`2`, and `1`, they would move forward 5 times, to spaces `8`, `9`, `10`,
`1`, and finally stopping on `2`.

After each player moves, they increase their **score** by the value of the
space their pawn stopped on. Players' scores start at `0`. So, if the
first player starts on space `7` and rolls a total of `5`, they would
stop on space `2` and add `2` to their score (for a total score of `2`).
The game immediately ends as a win for any player whose score reaches
**at least `1000`**.

Since the first game is a practice game, the submarine opens a
compartment labeled **deterministic dice** and a 100-sided die falls out.
This die always rolls `1` first, then `2`, then `3`, and so on up to
`100`, after which it starts over at `1` again. Play using this die.

For example, given these starting positions:

```
    Player 1 starting position: 4
    Player 2 starting position: 8
```

This is how the game would go:

-   Player 1 rolls `1`+`2`+`3` and moves to space `10` for a total score
    of `10`.
-   Player 2 rolls `4`+`5`+`6` and moves to space `3` for a total score
    of `3`.
-   Player 1 rolls `7`+`8`+`9` and moves to space `4` for a total score
    of `14`.
-   Player 2 rolls `10`+`11`+`12` and moves to space `6` for a total
    score of `9`.
-   Player 1 rolls `13`+`14`+`15` and moves to space `6` for a total
    score of `20`.
-   Player 2 rolls `16`+`17`+`18` and moves to space `7` for a total
    score of `16`.
-   Player 1 rolls `19`+`20`+`21` and moves to space `6` for a total
    score of `26`.
-   Player 2 rolls `22`+`23`+`24` and moves to space `6` for a total
    score of `22`.

...after many turns...

-   Player 2 rolls `82`+`83`+`84` and moves to space `6` for a total
    score of `742`.
-   Player 1 rolls `85`+`86`+`87` and moves to space `4` for a total
    score of `990`.
-   Player 2 rolls `88`+`89`+`90` and moves to space `3` for a total
    score of `745`.
-   Player 1 rolls `91`+`92`+`93` and moves to space `10` for a final
    score, `1000`.

Since player 1 has at least `1000` points, player 1 wins and the game
ends. At this point, the losing player had `745` points and the die had
been rolled a total of `993` times; `745 * 993 = 739785`.

Play a practice game using the deterministic 100-sided die. The moment
either player wins, **what do you get if you multiply the score of the
losing player by the number of times the die was rolled during the
game?**

Your puzzle answer was `918081`.

## Part Two

Now that you're warmed up, it's time to play the real game.

A second compartment opens, this time labeled **Dirac dice**. Out of it
falls a single three-sided die.

As you experiment with the die, you feel a little strange. An
informational brochure in the compartment explains that this is a
**quantum die**: when you roll it, the universe **splits into multiple
copies**, one copy for each possible outcome of the die. In this case,
rolling the die always splits the universe into **three copies**: one
where the outcome of the roll was `1`, one where it was `2`, and one
where it was `3`.

The game is played the same as before, although to prevent things from
getting too far out of hand, the game now ends when either player's
score reaches at least `21`.

Using the same starting positions as in the example above, player 1 wins
in `444356092776315` universes, while player 2 merely wins in
`341960390180808` universes.

Using your given starting positions, determine every possible outcome.
**Find the player that wins in more universes; in how many universes does
that player win?**

### Part Two Design

#### Initial Thoughts

1. Doing AoC over the years has taught me a few things, and one is: When faced with exponential growth of a tree, you have to find some way to prune the branches faster than you create them. Caching can be a decent strategy for this.

1. A little napkin math to see if we're thinking clearly (or at least thinking we're thinking clearly); seems like we're in the ballpark:

```
[3] rolls per turn
avg 5.5 points per turn
21 / 5.5 = avg [5] turns to win
[2] players alternating
3 * 5 * 2 = 30

444356092776315 = P1 wins
341960390180808 = P2 wins
205891130000000 = 3-to-the-30

9223372036854775807 = max 64-bit unsigned integer
```

1. So we have to decide what represents node state (to use as the cache key). To know who won how many games below this node, we have to know:
   1. P1 and P2 position on board
   1. current P1 and P2 score
   1. whose turn it is, P1 or P2
   1. _not_ the number of turns to this point (irrelevant)

1. So some more napkin math on how many keys might be stored in the cache; surprisingly not that many:

```
P1 and P2 positions can be one of [10] values (1..10)
P1 and P2 scores can be one of [22] values (0..21 -- might be 20)
P1 or P2 can be the current player [2]
10 * 10 * 22 * 22 * 2 = 96800
```

1. It seems clear the tree has to be walked depth-first, because there's nothing to cache until you know a game outcome down at the leaf. From this it follows that we won't have to worry about tail recursion; the stack isn't going to grow much beyond 10 levels.

#### Algorithm

```
S = {P1pos, P2pos, P1score, P2score, Pturn}
O = {P1won, P2won}
```

1. Each node N represents a **player turn**. Recursion enters the node with state S.

1. The top node is the game starting state S0: The P1 and P2 positions are given by the puzzle input, the P1 and P2 scores are 0, and P1 starts.

1. It should compute the outcome of all 27 combinations (3 rolls of the 3-sided die), _i.e._ the change of state from current state S, yielding new states S1..S27.
   1. **TODO** Describe what a node does with any of the S1..27 states that are a winning outcome.

1. It should then call itself recursively 27 times, once with each of the S1..S27 states, each of which returns an outcome O1..O27.
   1. **TODO** Describe how the cache is used to avoid a recursive call.

1. _Insight:_ We don't actually have to do all 27; some of them will be duplicates, as anyone who's played [Can't Stop](https://en.wikipedia.org/wiki/Can%27t_Stop_%28board_game%29) knows.
   1. If we reduce the number of roll combinations, we need to remember to multiply the outcome by how many times each duplicate happens.
   1. Probably better to just let the cache handle this; simplifies the "roll up".

1. When finished, each node N should "roll up" the O1..O27 outcomes to create its own outcome O. O should be cached and returned to the parent.

1. The topmost call returns exactly the answer we need for the puzzle (how many games each player won).

1. Given that I'm using Elixir, the cache `Map` will have to be passed up and down the tree.
