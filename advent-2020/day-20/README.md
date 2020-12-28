# Day 20: Jurassic Jigsaw

## Part One

The high-speed train leaves the forest and quickly carries you south.
You can even see a desert in the distance! Since you have some spare
time, you might as well see if there was anything interesting in the
image the Mythical Information Bureau satellite captured.

After decoding the satellite messages, you discover that the data
actually contains many small images created by the satellite's **camera
array**. The camera array consists of many cameras; rather than produce a
single square image, they produce many smaller square image **tiles** that
need to be **reassembled back into a single image**.

Each camera in the camera array returns a single monochrome **image tile**
with a random unique **ID number**. The tiles (your puzzle input) arrived
in a random order.

Worse yet, the camera array appears to be malfunctioning: each image
tile has been **rotated and flipped to a random orientation**. Your first
task is to reassemble the original image by orienting the tiles so they
fit together.

To show how the tiles should be reassembled, each tile's image data
includes a border that should line up exactly with its adjacent tiles.
All tiles have this border, and the border lines up exactly when the
tiles are both oriented correctly. Tiles at the edge of the image also
have this border, but the outermost edges won't line up with any other
tiles.

For example, suppose you have the following nine tiles:

    Tile 2311:
    ..##.#..#.
    ##..#.....
    #...##..#.
    ####.#...#
    ##.##.###.
    ##...#.###
    .#.#.#..##
    ..#....#..
    ###...#.#.
    ..###..###

    Tile 1951:
    #.##...##.
    #.####...#
    .....#..##
    #...######
    .##.#....#
    .###.#####
    ###.##.##.
    .###....#.
    ..#.#..#.#
    #...##.#..

    Tile 1171:
    ####...##.
    #..##.#..#
    ##.#..#.#.
    .###.####.
    ..###.####
    .##....##.
    .#...####.
    #.##.####.
    ####..#...
    .....##...

    Tile 1427:
    ###.##.#..
    .#..#.##..
    .#.##.#..#
    #.#.#.##.#
    ....#...##
    ...##..##.
    ...#.#####
    .#.####.#.
    ..#..###.#
    ..##.#..#.

    Tile 1489:
    ##.#.#....
    ..##...#..
    .##..##...
    ..#...#...
    #####...#.
    #..#.#.#.#
    ...#.#.#..
    ##.#...##.
    ..##.##.##
    ###.##.#..

    Tile 2473:
    #....####.
    #..#.##...
    #.##..#...
    ######.#.#
    .#...#.#.#
    .#########
    .###.#..#.
    ########.#
    ##...##.#.
    ..###.#.#.

    Tile 2971:
    ..#.#....#
    #...###...
    #.#.###...
    ##.##..#..
    .#####..##
    .#..####.#
    #..#.#..#.
    ..####.###
    ..#.#.###.
    ...#.#.#.#

    Tile 2729:
    ...#.#.#.#
    ####.#....
    ..#.#.....
    ....#..#.#
    .##..##.#.
    .#.####...
    ####.#.#..
    ##.####...
    ##..#.##..
    #.##...##.

    Tile 3079:
    #.#.#####.
    .#..######
    ..#.......
    ######....
    ####.#..#.
    .#...#.##.
    #.#####.##
    ..#.###...
    ..#.......
    ..#.###...

By rotating, flipping, and rearranging them, you can find a square
arrangement that causes all adjacent borders to line up:

    #...##.#.. ..###..### #.#.#####.
    ..#.#..#.# ###...#.#. .#..######
    .###....#. ..#....#.. ..#.......
    ###.##.##. .#.#.#..## ######....
    .###.##### ##...#.### ####.#..#.
    .##.#....# ##.##.###. .#...#.##.
    #...###### ####.#...# #.#####.##
    .....#..## #...##..#. ..#.###...
    #.####...# ##..#..... ..#.......
    #.##...##. ..##.#..#. ..#.###...

    #.##...##. ..##.#..#. ..#.###...
    ##..#.##.. ..#..###.# ##.##....#
    ##.####... .#.####.#. ..#.###..#
    ####.#.#.. ...#.##### ###.#..###
    .#.####... ...##..##. .######.##
    .##..##.#. ....#...## #.#.#.#...
    ....#..#.# #.#.#.##.# #.###.###.
    ..#.#..... .#.##.#..# #.###.##..
    ####.#.... .#..#.##.. .######...
    ...#.#.#.# ###.##.#.. .##...####

    ...#.#.#.# ###.##.#.. .##...####
    ..#.#.###. ..##.##.## #..#.##..#
    ..####.### ##.#...##. .#.#..#.##
    #..#.#..#. ...#.#.#.. .####.###.
    .#..####.# #..#.#.#.# ####.###..
    .#####..## #####...#. .##....##.
    ##.##..#.. ..#...#... .####...#.
    #.#.###... .##..##... .####.##.#
    #...###... ..##...#.. ...#..####
    ..#.#....# ##.#.#.... ...##.....

For reference, the IDs of the above tiles are:

    1951    2311    3079
    2729    1427    2473
    2971    1489    1171

To check that you've assembled the image correctly, multiply the IDs of
the four corner tiles together. If you do this with the assembled tiles
from the example above, you get `1951 * 3079 * 2971 * 1171` =
**`20899048083289`**.

Assemble the tiles into an image. **What do you get if you multiply
together the IDs of the four corner tiles?**

Your puzzle answer was `11788777383197`.

### Part One Design

Every AoC year seems to have one death march, and this year it was Day 20 for me. I spent all day Sunday, December 20, 2020, hacking more and more grotesque functions, trying to get the answer so I'd have something to refactor against. See commit `410ed90` (`solve()` et al) for what that got me... about 350 lines of horror, most of a wasted day, and an inadequate base for part 2 to build on.

The lessons here were:

1. **Stop and think.** It's one thing to have the code be a little messy, and you can go back and refactor after you have the solution and some tests to refactor against. But when the code devolves into hundreds of lines of trash, it is telling you you're on the wrong track.
1. **Break the problem into smaller chunks.** Big functions are always trying to do too much. Not only should you break them into smaller ones (with independent tests), but stop and think (again) about what the sub-problems are on the path to the solution. At some point, copying and pasting will waste your time rather than saving it.
1. **Don't be afraid to abandon a path.** In the spirit of Kent Beck's "(T&C)|R" ("test and commit, or revert"), if a much better approach occurs to you partway through a heavy slog, don't surrender to the sunk cost fallacy. You'll probably be happier wiping it out and starting over now... given that you may have to do it anyway when the first approach is finished and doesn't work.

## Part Two

Now, you're ready to **check the image for sea monsters**.

The borders of each tile are not part of the actual image; start by
removing them.

In the example above, the tiles become:

    .#.#..#. ##...#.# #..#####
    ###....# .#....#. .#......
    ##.##.## #.#.#..# #####...
    ###.#### #...#.## ###.#..#
    ##.#.... #.##.### #...#.##
    ...##### ###.#... .#####.#
    ....#..# ...##..# .#.###..
    .####... #..#.... .#......

    #..#.##. .#..###. #.##....
    #.####.. #.####.# .#.###..
    ###.#.#. ..#.#### ##.#..##
    #.####.. ..##..## ######.#
    ##..##.# ...#...# .#.#.#..
    ...#..#. .#.#.##. .###.###
    .#.#.... #.##.#.. .###.##.
    ###.#... #..#.##. ######..

    .#.#.### .##.##.# ..#.##..
    .####.## #.#...## #.#..#.#
    ..#.#..# ..#.#.#. ####.###
    #..####. ..#.#.#. ###.###.
    #####..# ####...# ##....##
    #.##..#. .#...#.. ####...#
    .#.###.. ##..##.. ####.##.
    ...###.. .##...#. ..#..###

Remove the gaps to form the actual image:

    .#.#..#.##...#.##..#####
    ###....#.#....#..#......
    ##.##.###.#.#..######...
    ###.#####...#.#####.#..#
    ##.#....#.##.####...#.##
    ...########.#....#####.#
    ....#..#...##..#.#.###..
    .####...#..#.....#......
    #..#.##..#..###.#.##....
    #.####..#.####.#.#.###..
    ###.#.#...#.######.#..##
    #.####....##..########.#
    ##..##.#...#...#.#.#.#..
    ...#..#..#.#.##..###.###
    .#.#....#.##.#...###.##.
    ###.#...#..#.##.######..
    .#.#.###.##.##.#..#.##..
    .####.###.#...###.#..#.#
    ..#.#..#..#.#.#.####.###
    #..####...#.#.#.###.###.
    #####..#####...###....##
    #.##..#..#...#..####...#
    .#.###..##..##..####.##.
    ...###...##...#...#..###

Now, you're ready to search for sea monsters! Because your image is
monochrome, a sea monster will look like this:

                      # 
    #    ##    ##    ###
     #  #  #  #  #  #   

When looking for this pattern in the image, **the spaces can be
anything**; only the `#` need to match. Also, you might need to rotate or
flip your image before it's oriented correctly to find sea monsters. In
the above image, **after flipping and rotating it** to the appropriate
orientation, there are **two** sea monsters (marked with `O`):

    .####...#####..#...###..
    #####..#..#.#.####..#.#.
    .#.#...#.###...#.##.O#..
    #.O.##.OO#.#.OO.##.OOO##
    ..#O.#O#.O##O..O.#O##.##
    ...#.#..##.##...#..#..##
    #.##.#..#.#..#..##.#.#..
    .###.##.....#...###.#...
    #.####.#.#....##.#..#.#.
    ##...#..#....#..#...####
    ..#.##...###..#.#####..#
    ....#.##.#.#####....#...
    ..##.##.###.....#.##..#.
    #...#...###..####....##.
    .#.##...#.##.#.#.###...#
    #.###.#..####...##..#...
    #.###...#.##...#.##O###.
    .O##.#OO.###OO##..OOO##.
    ..O#.O..O..O.#O##O##.###
    #.#..##.########..#..##.
    #.#####..#.#...##..#....
    #....##..#.#########..##
    #...#.....#..##...###.##
    #..###....##.#...##.##.#

Determine how rough the waters are in the sea monsters' habitat by
counting the number of `#` that are **not** part of a sea monster. In the
above example, the habitat's water roughness is **`273`**.

**How many `#` are not part of a sea monster?**

Your puzzle answer was `2242`.

### Part Two Design

I was so disgusted with part 1 that I actually moved on and created part 2 code that worked for the example, before returning to the part 1 tile alignment search code.

...and then I put it all together and got the wrong answer for part 2. After a bit more wandering in the wilderness I re-read the puzzle description, and discovered the code was fine; I had forgotten what quantity part 2 was actually asking for.
