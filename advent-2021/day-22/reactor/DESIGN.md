### Part One Design

#### Initial Thoughts

We know what's coming for part 2; tracking each individual cube isn't going to be feasible then. We need to convert the steps into a set of deltas. Tricky bits:

1. For part 1, "The initialization procedure only uses cubes that have x, y, and z positions of at least -50 and at most 50. For now, ignore cubes outside this region. \[...] \[In the example:] The last two steps are fully outside the initialization procedure area; all other steps are fully within it."

    1. This might be a trap; some of those big-looking entries in the real puzzle input might not be "fully outside the initialization procedure area".

    1. We're going to need an intersection function anyway; use it to test vs. the initialization procedure area.

    1. Also verify that for range `A..B` that `A <= B` always

1. "The reactor core is made up of a large 3-dimensional grid made up entirely of cubes, [...] at the start of the reboot process, they are all off."

    1. We don't know how big the reactor is; essentially we've got an infinite volume.

    1. A step that turns off cubes that don't intersect with any previous steps gives a delta of 0, not -1.

1. I first worked through an example in 2D where I reduced each step to a delta of cubes turned on or off. It quickly became clear that if I considered each step pairwise with previous steps, I'd end up double-counting... and the infinite void of "off" cubes would be troublesome.

#### Algorithm

Have each step split previous cuboids into multiple new cuboids, based on how they intersect.

```
on x=3..7,y=3..7
off x=5..9,y=5..9
on x=2..6,y=2..6
off x=6..9,y=3..9
```

step 1 ("on")
- has nothing to reduce
- creates cuboid A
- total cubes lit = +25 = 25
```
..........
..........
..........
...AAAAA..
...AAAAA..
...AAAAA..
...AAAAA..
...AAAAA..
..........
..........
```

step 2 ("off")
- splits cuboid A into A,B which fall outside intersection
- total cubes lit = +25 -9 = +10 +6 = 16
```
..........
..........
..........
...AAAAA..
...AAAAA..
...BB.....
...BB.....
...BB.....
..........
..........
```

step 3 ("on")
- reduces cuboid A,B to what falls outside intersection
- creates cuboid C
- total cubes lit = +25 -9 +13 = 1\*2 + 2\*1 + 5\*5 = 29
```
..........
..........
..CCCCC...
..CCCCCA..
..CCCCCA..
..CCCCC...
..CCCCC...
...BB.....
..........
..........
```

step 4 ("off")
- removes cuboid A (wholly contained)
- leaves cuboid B alone (doesn't intersect)
- splits cuboid C into C,D which fall outside intersection
- total cubes lit = +25 -9 +13 -6 = 2\*1 + 5\*1 + 4\*4 = 23
```
..........
..........
..CCCCC...
..CCCC+--+
..CCCC|  |
..CCCC|  |
..CCCC|  |
...BB.|  |
......|  |
......+--+

..........
..........
..CCCCC...
..DDDD....
..DDDD....
..DDDD....
..DDDD....
...BB.....
..........
..........
```

The rules would seem to be:

1. for an "on" step:
   - remove previous cuboids wholly contained by this step's dimensions
   - reduce each previous cuboid to new cuboids composed of cubes which fall outside the intersection
     - in 3D, this will create up to 6 new cuboids (test all the combinations!)
   - leave unchanged previous cuboids which don't intersect this step's dimensions
   - create new cuboid of this step's dimensions

1. for an "off" step:
   - remove previous cuboids wholly contained by this step's dimensions
   - reduce each previous cuboid to new cuboids composed of cubes which fall outside the intersection
     - in 3D, this will create up to 6 new cuboids
   - leave unchanged previous cuboids which don't intersect this step's dimensions
   - (don't create anything else)

1. (test:) assert that the resulting list of cuboids has no pairwise intersections
