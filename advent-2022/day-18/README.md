# Day 18: Boiling Boulders

## Part One

You and the elephants finally reach fresh air. You've emerged near the
base of a large volcano that seems to be actively erupting! Fortunately,
the lava seems to be flowing away from you and toward the ocean.

Bits of lava are still being ejected toward you, so you're sheltering in
the cavern exit a little longer. Outside the cave, you can see the lava
landing in a pond and hear it loudly hissing as it solidifies.

Depending on the specific compounds in the lava and speed at which it
cools, it might be forming
[obsidian](https://en.wikipedia.org/wiki/Obsidian)! The cooling rate
should be based on the surface area of the lava droplets, so you take a
quick scan of a droplet as it flies past you (your puzzle input).

Because of how quickly the lava is moving, the scan isn't very good; its
resolution is quite low and, as a result, it approximates the shape of
the lava droplet with **1x1x1 cubes on a 3D grid**, each given as its
`x,y,z` position.

To approximate the surface area, count the number of sides of each cube
that are not immediately connected to another cube. So, if your scan
were only two adjacent cubes like `1,1,1` and `2,1,1`, each cube would
have a single side covered and five sides exposed, a total surface area
of `10` sides.

Here's a larger example:

```
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
```

In the above example, after counting up all the sides that aren't
connected to another cube, the total surface area is `64`.

**What is the surface area of your scanned lava droplet?**

Your puzzle answer was `3448`.

## Part Two

Something seems off about your calculation. The cooling rate depends on
exterior surface area, but your calculation also included the surface
area of air pockets trapped in the lava droplet.

Instead, consider only cube sides that could be reached by the water and
steam as the lava droplet tumbles into the pond. The steam will expand
to reach as much as possible, completely displacing any air on the
outside of the lava droplet but never expanding diagonally.

In the larger example above, exactly one cube of air is trapped within
the lava droplet (at `2,2,5`), so the exterior surface area of the lava
droplet is `58`.

**What is the exterior surface area of your scanned lava droplet?**

Your puzzle answer was `2052`.

### Part Two Design

> **Spoilers ahead!**

Part 1 came together easily. When I read part 2, I was picturing a completely sealed cavern inside the droplet, and I thought, "Aha! That's essentially just a mirror image of the outer object. Make a list of the interior air cubes, run the part 1 surface area method, and subtract." Well of course that would have been too easy :) -- it worked for the puzzle example but not my puzzle input.

After getting some sleep, I re-read part 2, and pondered what this might mean:

> The steam will expand to reach as much as possible, completely displacing any air on the outside of the lava droplet

Eventually it dawned on me that there might be a tunnel to the inside. My part 1 solution (which calculates based on lava cubes that touch along an axis) wouldn't work for that case.

As is often the case in AoC, it helps to visualize the object. I poked around online and didn't find a quick way to render the droplet in 3D (would be a good exercise at some point). I tried a "plane-by-plane slice" dumper, which made the puzzle example clearer but was too hard to see with the big puzzle input droplet.

So I decided to just go for it. I came up with this way to find the surface area that would work if there was a tunnel:

1. Find the dimensions of the "box" that contains the droplet. Include one extra plane of air cubes on each of the six faces.

1. Start at any corner of the "box" and recursively walk. BFS seemed safest but it seems like DFS would have worked too? Check each of the six neighbor cubes\*:
   1. if it's outside the "box": do nothing
   1. if it's a lava cube: add one face to the surface area count
   1. if it's an unvisited air cube: add it to the list of cubes to visit

And it worked! This will also properly handle a droplet that has a sealed cavern (those air cubes won't be reached by the walk).

\* Deciding which cubes are "neighbors" made me realize why this is in the part 2 description:

> but never expanding diagonally
