# Day 19: Beacon Scanner

## Part One

As your [probe](../day-17) drifted down through this area, it released an
assortment of **beacons** and **scanners** into the water. It's difficult to
navigate in the pitch black open waters of the ocean trench, but if you
can build a map of the trench using data from the scanners, you should
be able to safely reach the bottom.

The beacons and scanners float motionless in the water; they're designed
to maintain the same position for long periods of time. Each scanner is
capable of detecting all beacons in a large cube centered on the
scanner; beacons that are at most 1000 units away from the scanner in
each of the three axes (`x`, `y`, and `z`) have their precise position
determined relative to the scanner. However, scanners cannot detect
other scanners. The submarine has automatically summarized the relative
positions of beacons detected by each scanner (your puzzle input).

For example, if a scanner is at `x,y,z` coordinates `500,0,-500` and
there are beacons at `-500,1000,-1500` and `1501,0,-500`, the scanner
could report that the first beacon is at `-1000,1000,-1000` (relative to
the scanner) but would not detect the second beacon at all.

Unfortunately, while each scanner can report the positions of all
detected beacons relative to itself, **the scanners do not know their own
position**. You'll need to determine the positions of the beacons and
scanners yourself.

The scanners and beacons map a single contiguous 3d region. This region
can be reconstructed by finding pairs of scanners that have overlapping
detection regions such that there are **at least 12 beacons** that both
scanners detect within the overlap. By establishing 12 common beacons,
you can precisely determine where the scanners are relative to each
other, allowing you to reconstruct the beacon map one scanner at a time.

For a moment, consider only two dimensions. Suppose you have the
following scanner reports:

```
    --- scanner 0 ---
    0,2
    4,1
    3,3

    --- scanner 1 ---
    -1,-1
    -5,0
    -2,1
```

Drawing `x` increasing rightward, `y` increasing upward, scanners as
`S`, and beacons as `B`, scanner `0` detects this:

```
    ...B.
    B....
    ....B
    S....
```

Scanner `1` detects this:

```
    ...B..
    B....S
    ....B.
```

For this example, assume scanners only need 3 overlapping beacons. Then,
the beacons visible to both scanners overlap to produce the following
complete map:

```
    ...B..
    B....S
    ....B.
    S.....
```

Unfortunately, there's a second problem: the scanners also don't know
their **rotation or facing direction**. Due to magnetic alignment, each
scanner is rotated some integer number of 90-degree turns around all of
the `x`, `y`, and `z` axes. That is, one scanner might call a direction
positive `x`, while another scanner might call that direction negative
`y`. Or, two scanners might agree on which direction is positive `x`,
but one scanner might be upside-down from the perspective of the other
scanner. In total, each scanner could be in any of 24 different
orientations: facing positive or negative `x`, `y`, or `z`, and
considering any of four directions "up" from that facing.

For example, here is an arrangement of beacons as seen from a scanner in
the same position but in different orientations:

```
    --- scanner 0 ---
    -1,-1,1
    -2,-2,2
    -3,-3,3
    -2,-3,1
    5,6,-4
    8,0,7

    --- scanner 0 ---
    1,-1,1
    2,-2,2
    3,-3,3
    2,-1,3
    -5,4,-6
    -8,-7,0

    --- scanner 0 ---
    -1,-1,-1
    -2,-2,-2
    -3,-3,-3
    -1,-3,-2
    4,6,5
    -7,0,8

    --- scanner 0 ---
    1,1,-1
    2,2,-2
    3,3,-3
    1,3,-2
    -4,-6,5
    7,0,8

    --- scanner 0 ---
    1,1,1
    2,2,2
    3,3,3
    3,1,2
    -6,-4,-5
    0,7,-8
```

By finding pairs of scanners that both see at least 12 of the same
beacons, you can assemble the entire map. For example, consider the
following report:

```
    --- scanner 0 ---
    404,-588,-901
    528,-643,409
    -838,591,734
    390,-675,-793
    -537,-823,-458
    -485,-357,347
    -345,-311,381
    -661,-816,-575
    -876,649,763
    -618,-824,-621
    553,345,-567
    474,580,667
    -447,-329,318
    -584,868,-557
    544,-627,-890
    564,392,-477
    455,729,728
    -892,524,684
    -689,845,-530
    423,-701,434
    7,-33,-71
    630,319,-379
    443,580,662
    -789,900,-551
    459,-707,401

    --- scanner 1 ---
    686,422,578
    605,423,415
    515,917,-361
    -336,658,858
    95,138,22
    -476,619,847
    -340,-569,-846
    567,-361,727
    -460,603,-452
    669,-402,600
    729,430,532
    -500,-761,534
    -322,571,750
    -466,-666,-811
    -429,-592,574
    -355,545,-477
    703,-491,-529
    -328,-685,520
    413,935,-424
    -391,539,-444
    586,-435,557
    -364,-763,-893
    807,-499,-711
    755,-354,-619
    553,889,-390

    --- scanner 2 ---
    649,640,665
    682,-795,504
    -784,533,-524
    -644,584,-595
    -588,-843,648
    -30,6,44
    -674,560,763
    500,723,-460
    609,671,-379
    -555,-800,653
    -675,-892,-343
    697,-426,-610
    578,704,681
    493,664,-388
    -671,-858,530
    -667,343,800
    571,-461,-707
    -138,-166,112
    -889,563,-600
    646,-828,498
    640,759,510
    -630,509,768
    -681,-892,-333
    673,-379,-804
    -742,-814,-386
    577,-820,562

    --- scanner 3 ---
    -589,542,597
    605,-692,669
    -500,565,-823
    -660,373,557
    -458,-679,-417
    -488,449,543
    -626,468,-788
    338,-750,-386
    528,-832,-391
    562,-778,733
    -938,-730,414
    543,643,-506
    -524,371,-870
    407,773,750
    -104,29,83
    378,-903,-323
    -778,-728,485
    426,699,580
    -438,-605,-362
    -469,-447,-387
    509,732,623
    647,635,-688
    -868,-804,481
    614,-800,639
    595,780,-596

    --- scanner 4 ---
    727,592,562
    -293,-554,779
    441,611,-461
    -714,465,-776
    -743,427,-804
    -660,-479,-426
    832,-632,460
    927,-485,-438
    408,393,-506
    466,436,-512
    110,16,151
    -258,-428,682
    -393,719,612
    -211,-452,876
    808,-476,-593
    -575,615,604
    -485,667,467
    -680,325,-822
    -627,-443,-432
    872,-547,-609
    833,512,582
    807,604,487
    839,-516,451
    891,-625,532
    -652,-548,-490
    30,-46,-14
```

Because all coordinates are relative, in this example, all "absolute"
positions will be expressed relative to scanner `0` (using the
orientation of scanner `0` and as if scanner `0` is at coordinates
`0,0,0`).

Scanners `0` and `1` have overlapping detection cubes; the 12 beacons
they both detect (relative to scanner `0`) are at the following
coordinates:

```
    -618,-824,-621
    -537,-823,-458
    -447,-329,318
    404,-588,-901
    544,-627,-890
    528,-643,409
    -661,-816,-575
    390,-675,-793
    423,-701,434
    -345,-311,381
    459,-707,401
    -485,-357,347
```

These same 12 beacons (in the same order) but from the perspective of
scanner `1` are:

```
    686,422,578
    605,423,415
    515,917,-361
    -336,658,858
    -476,619,847
    -460,603,-452
    729,430,532
    -322,571,750
    -355,545,-477
    413,935,-424
    -391,539,-444
    553,889,-390
```

Because of this, scanner `1` must be at `68,-1246,-43` (relative to
scanner `0`).

Scanner `4` overlaps with scanner `1`; the 12 beacons they both detect
(relative to scanner `0`) are:

```
    459,-707,401
    -739,-1745,668
    -485,-357,347
    432,-2009,850
    528,-643,409
    423,-701,434
    -345,-311,381
    408,-1815,803
    534,-1912,768
    -687,-1600,576
    -447,-329,318
    -635,-1737,486
```

So, scanner `4` is at `-20,-1133,1061` (relative to scanner `0`).

Following this process, scanner `2` must be at `1105,-1205,1229`
(relative to scanner `0`) and scanner `3` must be at `-92,-2380,-20`
(relative to scanner `0`).

The full list of beacons (relative to scanner `0`) is:

```
    -892,524,684
    -876,649,763
    -838,591,734
    -789,900,-551
    -739,-1745,668
    -706,-3180,-659
    -697,-3072,-689
    -689,845,-530
    -687,-1600,576
    -661,-816,-575
    -654,-3158,-753
    -635,-1737,486
    -631,-672,1502
    -624,-1620,1868
    -620,-3212,371
    -618,-824,-621
    -612,-1695,1788
    -601,-1648,-643
    -584,868,-557
    -537,-823,-458
    -532,-1715,1894
    -518,-1681,-600
    -499,-1607,-770
    -485,-357,347
    -470,-3283,303
    -456,-621,1527
    -447,-329,318
    -430,-3130,366
    -413,-627,1469
    -345,-311,381
    -36,-1284,1171
    -27,-1108,-65
    7,-33,-71
    12,-2351,-103
    26,-1119,1091
    346,-2985,342
    366,-3059,397
    377,-2827,367
    390,-675,-793
    396,-1931,-563
    404,-588,-901
    408,-1815,803
    423,-701,434
    432,-2009,850
    443,580,662
    455,729,728
    456,-540,1869
    459,-707,401
    465,-695,1988
    474,580,667
    496,-1584,1900
    497,-1838,-617
    527,-524,1933
    528,-643,409
    534,-1912,768
    544,-627,-890
    553,345,-567
    564,392,-477
    568,-2007,-577
    605,-1665,1952
    612,-1593,1893
    630,319,-379
    686,-3108,-505
    776,-3184,-501
    846,-3110,-434
    1135,-1161,1235
    1243,-1093,1063
    1660,-552,429
    1693,-557,386
    1735,-437,1738
    1749,-1800,1813
    1772,-405,1572
    1776,-675,371
    1779,-442,1789
    1780,-1548,337
    1786,-1538,337
    1847,-1591,415
    1889,-1729,1762
    1994,-1805,1792
```

In total, there are `79` beacons.

Assemble the full map of beacons. **How many beacons are there?**

Your puzzle answer was `436`.

### Part One Design

> **Spoilers ahead!**

#### Initial Thoughts

1. There was a puzzle in a previous year that dealt with rotations and orientations... ah, [AoC 2020 Day 20](../../advent-2020/day-20) (though that one was only in 2D). I re-read my notes from that one; it was a death march. Let's not fall into that trap.

1. If my math were stronger, I bet [Nx](https://github.com/elixir-nx/nx) would be great for this.

1. Why 24 possible scanner orientations? [This Stack Overflow answer](https://stackoverflow.com/a/16467849/291754) has a good way to think about it:

> "A die [...] is handy for observing the 24 different orientations, and can suggest operation sequences to generate them. You will see that any of six faces can be uppermost, and the sides below can be rotated into four different cardinal directions."

1. Why a minimum of 12 beacons in common? There's some interesting discussion of the math behind it on [this AoC Reddit post](https://www.reddit.com/r/adventofcode/comments/rk4mvb/2021_day_19_why_12/).

#### Algorithm Attempt 1

I came up with this algorithm:

1. As with the puzzle example, we'll arbitrarily choose scanner 0 to be the frame of reference (its location will be the (0,0,0) origin point, and its orientation will be the identity transform).

1. For any scanner n, can we find 12 points in the same scanner n transformation T, such that `{i0, j0, k0} = T{in, jn, kn} + {ic, jc, kc}`, given some constant relative position c between the two scanners?

1. And it worked! A quick experiment with the puzzle example ("scanner 1 must be at 68,-1246,-43 (relative to scanner 0)"), (1) using all combinations of scanner 0 beacons, scanner 1 beacons, and 24 transformations of scanner 1, (2) calculating the offsets (vector subtraction), and (3) finding the offset with the most occurrences, yields this:

```
scanners[0] count: 25
scanners[1] count: 25
n_offsets: 15000
highest transform,pos and count: {{9, {68, -1246, -43}}, 12}
```

#### Stuck

I finished a real implementation which passed the puzzle example... but then got stuck on my (real, larger) input.

1. The first thing to check was that my 24 transformations were right; see [this](https://www.reddit.com/r/adventofcode/comments/rjwckn/2021_day_19haskell_why_are_some_scanners_not/hp7sxz0/).
   1. I wrote a test that verified I get 24 unique values; that _seemed_ to validate the transform code. (<- Writers call this "foreshadowing".)
   1. Later I also tried to verify that correlation was commutative (if scanner 0 correlates to 1, then 1 should correlate to 0).

1. I put in a ton of debug output for the correlator and watched what it was doing. It was often able to find 3 or 6 beacons in common that all had the same transform and offset, but not 12. Were those the missing correlations; did I have a bug somewhere? (Lowering the requirement to 3 beacons, _i.e._ cheating, didn't help; it still got stuck.)

1. I scanned all the "Help" posts on the AoC Reddit; as of 11pm Sunday, nothing else jumped out.

1. Only one thing still puzzled me, and that's the vector length issue; why was "beacons that are at most 1000 units away from the scanner" included in the puzzle description?

#### Algorithm Attempt 2

Eventually I thought of one possible scenario. Picture the detection range of scanner S as a cube. Suppose it tries to correlate to all the scanners; it finds 3 beacons in common with scanner A in one of its corners, 3 with B in a different corner, and 6 with C in yet a different corner... but no single scanner that has 12. This might be what those "3 or 6 beacons in common" were (mentioned above)?

The solution would be: Each time we correlate a new scanner, merge the newly-found beacons into the list **then**, rather than waiting until the end. As the list of beacons grows, eventually "scanner S" will be able to find 12 from the whole group. This also had the advantage of making the code simpler and faster, so I went with it.

And it still didn't work!

#### The Solution

> "I couldn't figure out why the sun wasn't coming up! And then it dawned on me."

I don't know what prompted me to go back to my transformation code, but I did... and I finally found the bug. I had tried to be a mathematician and failed. (Again.) The source document I was working from (see below) was excellent, but was missing the Z rotation, and I thought I could figure it out myself.

Lessons learned:

1. When being an amateur mathematician, test early and often. Try to think of multiple ways to test that the math is right.

1. Question your assumptions. The transformation code was so easy to write, and the correlation code so tedious and fiddly, that I went too long assuming the bug must be somewhere in the latter.

### Thoughts On Performance

My current code is rather slow (takes about a minute); how can we improve it?

1. Rather than doing the full set of S0 * Sn * T calculations, when we find the first duplicate, could we stop and try all for that transformation to see if there are 12?

1. Rather than trying all the remaining scanners in some arbitrary order, is there a way to narrow which one(s) we try to correlate next? The puzzle description explains that "beacons that are at most 1000 units away from the scanner" can be seen; seems like that should fit in somewhere.

1. There is a [different and much faster approach](https://www.reddit.com/r/adventofcode/comments/rkuov0/i_need_help_understanding_day_19/hpc2lol/) that has to do with measuring the lengths of the vectors?

### What Are The 24 Transformations?

[This is essentially what I figured out for AoC 2020 Day 20, but now in 3D. It will probably come in handy in future AoC years.]

#### How To Rotate Around Each Axis

Putting together several other answers on [this Stack Overflow question](https://stackoverflow.com/q/16452383/291754) yields the following.

> Rotating a 3D array around the x-axis means that the element at position (i,j,k) will be mapped to position (i,-k,j).

> Similarly, rotating around the y-axis maps (i,j,k) to (k,j,-i).

So I derived the third possibility, rotating around the z-axis. The correct mapping is from (i,j,k) to (j,-i,k). (I got it wrong at first; see below.)

```
For the x-axis rotation:

|i'|   |1  0  0| |i|
|j'| = |0  0 -1|*|j|
|k'|   |0  1  0| |k|

For the y-axis rotation:

|i'|   |0  0  1| |i|
|j'| = |0  1  0|*|j|
|k'|   |-1 0  0| |k|

[So I derived the z-axis rotation, INCORRECTLY, by a process of elimination:]

|i'|   |0 -1  0| |i|   WRONG
|j'| = |1  0  0|*|j|   WRONG
|k'|   |0  0  1| |k|

[I mean c'mon... doesn't it _look_ right? The -1 appears exactly once in each row and column in the three rotation matrices. Such beautiful symmetry.]

[Here is the CORRECT z-axis rotation matrix:]

|i'|   |0  1  0| |i|
|j'| = |-1 0  0|*|j|
|k'|   |0  0  1| |k|
```

> Any general rotation can be described as a sequence of those [...] rotations.

#### Unique Rotation Sequences

> if you also use Z, a 90 degree rotation around the Z axis, then 4 rotations suffice:

```
1.  I = XXXX = YYYY = ZZZZ
2.  X = YXZ
3.  Y = ZYX
4.  Z = XZY
5.  XX = XYXZ = YXXY = YXYZ = YXZX = YYZZ = YZXZ = ZXXZ = ZZYY
6.  XY = YZ = ZX = XZYX = YXZY = ZYXZ
7.  XZ = XXZY = YXZZ = YYYX = ZYYY
8.  YX = XZZZ = YYXZ = ZYXX = ZZZY
9.  YY = XXZZ = XYYX = YZYX = ZXYX = ZYXY = ZYYZ = ZYZX = ZZXX
10. ZY = XXXZ = XZYY = YXXX = ZZYX
11. ZZ = XXYY = XYZY = XZXY = XZYZ = XZZX = YYXX = YZZY = ZXZY
12. XXX
13. XXY = XYZ = XZX = YZZ = ZXZ
14. XXZ = ZYY
15. XYX = YXY = YYZ = YZX = ZXX
16. XYY = YZY = ZXY = ZYZ = ZZX
17. XZZ = YYX
18. YXX = ZZY
19. YYY
20. ZZZ
21. XXXY = XXYZ = XXZX = XYZZ = XZXZ = YZZZ = ZXZZ = ZYYX
22. XXYX = XYXY = XYYZ = XYZX = XZXX = YXYY = YYZY = YZXY = YZYZ = YZZX = ZXXY = ZXYZ = ZXZX = ZYZZ = ZZXZ
23. XYXX = XZZY = YXYX = YYXY = YYYZ = YYZX = YZXX = ZXXX
24. XYYY
```

## Part Two

Sometimes, it's a good idea to appreciate just how big the ocean is.
Using the
[Manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry),
how far apart do the scanners get?

In the above example, scanners `2` (`1105,-1205,1229`) and `3`
(`-92,-2380,-20`) are the largest Manhattan distance apart. In total,
they are `1197 + 1175 + 1249 = 3621` units apart.

**What is the largest Manhattan distance between any two scanners?**

Your puzzle answer was `10918`.
