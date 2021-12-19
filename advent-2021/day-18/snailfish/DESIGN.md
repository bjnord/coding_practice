# Redesign Thoughts

## Combine `find_explodable_context()` And `explode_at()`

1. do everything in one pass
   1. can get rid of `Enum.with_index()` entirely
   1. maybe one `Enum.split(5)` but otherwise no split/take

1. keep a set of stacks (each in reverse order)
   1. state: 5 stacks [start empty], indent level, post-explode-pair boolean
   1. bundle these in some container (tuple? map? struct?)

1. process
   1. start pushing tokens onto stack 1
   1. **every time** we see an integer [before exp. pair], move stack 1 contents to (top of) stack 0
      1. _i.e._ very top token on stack 0 is the (latest) prev integer
      1. this probably has to be a concatenate (`stack_0 = stack_0 ++ stack_1` and `stack_1 = []`)
      1. when done, either:
         1. stack 0 is empty (means no `prev` integer)
         1. topmost of stack 0 is the `prev` integer
   1. whenever we see open/close, adjust level
   1. when we see an open past 4th level, do the `simple_pair?()` as before
      1. if triggered:
         1. set the post-explode-pair flag
         1. pop the 5 pair tokens and put to stack 2 (backwards as they all are)
   1. now if we're post-explode-pair, push tokens onto top of stack **4**
   1. only **first time** we see an integer [after exp. pair], move stack 4 contents to stack 3
      1. this could be a replace (`stack_3 = stack_4` and `stack_4 = []`)
      1. when done, either:
         1. stack 3 is empty (means no `next` integer)
         1. topmost of stack 3 is the `next` integer

1. at end of token list we should have:
   1. stack 0: head w/prev at top [or empty]
   1. stack 1: lmiddle [always]
      1. if stack 0 is empty, lmiddle is essentially the head
   1. stack 2: the 5-token simple exploding pair [always]
   1. stack 3: rmiddle w/next at top [or empty]
   1. stack 4: tail [always]
      1. tail is always the tail

1. now we can do the explode
   1. stack 0/3 empty or not shows whether we have prev or next to combine l,r with
   1. stack 2 always gets replaced with `[0]`
   1. should be able to concatenate 4++3++2++1++0 and then reverse it

## Combine Explode and Split

1. keep things in tokens for **all** of `reduce()`
   1. only pay to-tokens/to-string cost once per `add()`

1. key insight on `reduce()`
   1. instructions say explode always goes first
   1. so when explode function reaches base case and **did explode** (created new token list)
      1. ...then call explode again recursively from the top!
   1. and then when we reach base case and **did not explode** (same tokens as previous)
      1. ...do a **single** split, and if it did split: call **explode** recursively again
   1. should be able to keep recursing down until neither explosion nor split happens
      1. ...and then return final token list to caller
