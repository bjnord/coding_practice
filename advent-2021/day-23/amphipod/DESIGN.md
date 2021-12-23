### Part One Design

#### Initial Thoughts

1. This sounds like a more complicated version of "Dirac Dice" (AoC 2021, Day 21, part 2), and potentially not cacheable. Maybe I should tackle that one first?

1. It's possible to test with a smaller game (2 types A and B, 2 rooms, shorter hallway). **Make the game resizable!**
   1. detect a shorter/longer board width and still work
   1. also detect shorter/longer cul-de-sacs on L and R edges

1. I'm a bit afraid of implementing a Dirac-style design for the simple game rules, given that part 2 could exponentially explode (see "Part Two Guesses" below) and render it useless. If I do, **don't take too long on it**.
   1. short-circuit the pathing by pretending players can pass each other in the hall
   1. leave cost calculation for later
   1. etc.

1. Each player will only move twice: once to somewhere in the hall, and once into their (final) room.
   1. For purposes of _move choice_ it doesn't matter which room location they choose; they should always just take the lowest location they can (no advantage to leaving a hole below them). The specific location only matters for:
      1. Determining where the player's next legal moves are (someone might block them).
      1. Determining if the game has hit a dead-end.

1. As with Dirac Dice this has to be depth-first.

#### Algorithm

1. Player attributes: type `t` in `0..nrooms-1`, number `n` in `0..nplayers-1`
   1. this way `type` is the same as `room`
1. Player state P:
   1. state `s` in `[:start, :hall, :home]`
   1. position `p` as `{x, y}`
   1. **not** energy consumed `e` (tracked as game move deltas)
1. Game state G:
   1. ordered moves so far `M[]`; `[1]` each move is:
      1. who: `Pn`
      1. what/where: `{s, {x, y}}` with `s` in `[:hall, :home]`
      1. expended energy (cost): `e`
   1. lowest-cost strategy found so far:
      1. ordered total moves `N[]` from start to finish
      1. total energy of solution `f`

1. Keep a `Map` "`{Players}`" of key=Pn value=Pstate (Ps,Pp}
1. Keep a `Map` "`{Board}`" of key=(x,y) value=P -- to use in determining legal move (who's blocking)

1. At each node in the game tree:
   1. Make a list of each player's remaining legal moves, along with energy expended (see `[1]` above)
      1. three basic kinds: `:start -> :hall` (n), `:hall -> :home` (1), `:start -> :home` (1)
      1. the to-hall move is the only one that has multiple subkinds
      1. all kinds have to do (1) pathing to see if they're blocked (2) move cost computation
   1. Eliminate those whose +cost goes above our currently found lowest-cost
   1. Call recursively by
      1. adding this move to `M[]`
      1. updating player state `P` (in `{Players}`) to reflect the move
      1. updating `{Board}` to say who is where
   1. Choose and return the lowest-cost `N[] + f` from the recursive calls

1. At the top node you'll have the puzzle answer.
   1. Make a `render()` function so we can replay the game after solution is found.

#### Napkin Math

1. there are 7 usable hallway locations (2 in each of 2 cul-de-sacs plus 3 between each pair of rooms)

1. worst-case is this; it should be a lot smaller once players get into the hallway and block each other

```
[8] players
[2] moves per player (to-hall choice + the only to-home move)
at most 6 players can move at any time (given 4 rooms + 2 cul-de-sacs)
- 4 players with 7 choices = [28]
- 2 players with 1 choice = [2]
8 * 2 * (28+2) = 480 tree depth
```

### Part Two Guesses

The complexity increase for part 2 could be one or more of these things:

1. Increasing the number of amphipod types: could be the same number of players per type (2); but lengthening the hallway and adding rooms, thus increasing the total number of players in the game.

1. Increasing the depth of the rooms: could be the same 4 types, but lengthening the hallway and adding rooms, thus increasing the total number of players in the game.

1. Removing one of the rule restrictions:

   1. Allowing them the use the space just outside the room.
   1. Allowing them to move to rooms other than their own ("Tower of Hanoi"-style).
   1. Allowing them to move from one hallway location to another.
