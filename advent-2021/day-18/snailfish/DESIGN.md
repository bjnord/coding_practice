# Design Thoughts

## Things We Need To Do

1. add two numbers (operands become new outest pair)
1. reduce a number
   1. detect an explodable pair
      1. "Exploding pairs will always consist of two regular numbers."
      1. "If any pair is nested inside four pairs, the leftmost such pair" is explodable.
   1. explode an explodable pair
      1. L slides/combines left, R slides/combines right, empty [] becomes a 0
      1. this has the effect of removing an inner layer of nesting
   1. detect a splittable number (n >= 10)
   1. split a splittable number
      1. number becomes a pair with L and R having half (R >= L)
1. compute a number's magnitude

## Questions

1. if a number has both explodable pair and splittable number, which is done first?
   - if unanswered, include code to detect this condition
     - at least raise exception
     - then try in either order, see if the answer changes

## Observations

1. these numbers aren't very long; `List` and `Enum` might not be too bad

## Choosing a Data Representation

May want different representations for different functions!
(This would require bidirectional conversion.)

1. alternatives
   1. keep them as strings, and do regex?
      - I don't know how to detect nesting level
      - _e.g._ `[[[[3, 4], [1, 2]], ...` has 5 `[` but isn't explodable
   1. parse them to an LR tree?
      - walking it to detect, and then replacing/merging, sounds hard
   1. break into tokens lexically? this seems best
      - `[[2, 3], 14]` -> `:o :o 2 :s 3 :c :s 14 :c`
      - split would be easy to detect and execute
      - explode also seems possible
