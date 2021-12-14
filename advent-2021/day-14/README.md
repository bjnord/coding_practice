# Day 14: Extended Polymerization

## Part One

The incredible pressures at this depth are starting to put a strain on
your submarine. The submarine has
[polymerization](https://en.wikipedia.org/wiki/Polymerization) equipment
that would produce suitable materials to reinforce the submarine, and
the nearby volcanically-active caves should even have the necessary
input elements in sufficient quantities.

The submarine manual contains instructions for finding the optimal
polymer formula; specifically, it offers a **polymer template** and a list
of **pair insertion** rules (your puzzle input). You just need to work out
what polymer would result after repeating the pair insertion process a
few times.

For example:

```
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
```

The first line is the **polymer template** - this is the starting point of
the process.

The following section defines the **pair insertion** rules. A rule like
`AB -> C` means that when elements `A` and `B` are immediately adjacent,
element `C` should be inserted between them. These insertions all happen
simultaneously.

So, starting with the polymer template `NNCB`, the first step
simultaneously considers all three pairs:

-   The first pair (`NN`) matches the rule `NN -> C`, so element `C` is
    inserted between the first `N` and the second `N`.
-   The second pair (`NC`) matches the rule `NC -> B`, so element `B` is
    inserted between the `N` and the `C`.
-   The third pair (`CB`) matches the rule `CB -> H`, so element `H` is
    inserted between the `C` and the `B`.

Note that these pairs overlap: the second element of one pair is the
first element of the next pair. Also, because all pairs are considered
simultaneously, inserted elements are not considered to be part of a
pair until the next step.

After the first step of this process, the polymer becomes `NCNBCHB`.

Here are the results of a few steps using the above rules:

```
    Template:     NNCB
    After step 1: NCNBCHB
    After step 2: NBCCNBBBCBHCB
    After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB
    After step 4: NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB
```

This polymer grows quickly. After step 5, it has length 97; After step
10, it has length 3073. After step 10, `B` occurs 1749 times, `C` occurs
298 times, `H` occurs 161 times, and `N` occurs 865 times; taking the
quantity of the most common element (`B`, 1749) and subtracting the
quantity of the least common element (`H`, 161) produces
`1749 - 161 = 1588`.

Apply 10 steps of pair insertion to the polymer template and find the
most and least common elements in the result. **What do you get if you
take the quantity of the most common element and subtract the quantity
of the least common element?**

Your puzzle answer was `3118`.

### Part One Design

Brute force, even though I knew _exactly_ what was coming next. I just wanted to get Part Two unlocked ASAP.

## Part Two

The resulting polymer isn't nearly strong enough to reinforce the
submarine. You'll need to run more steps of the pair insertion process;
a total of **40 steps** should do it.

In the above example, the most common element is `B` (occurring
`2192039569602` times) and the least common element is `H` (occurring
`3849876073` times); subtracting these produces `2188189693529`.

Apply **40** steps of pair insertion to the polymer template and find the
most and least common elements in the result. **What do you get if you
take the quantity of the most common element and subtract the quantity
of the least common element?**

### Part Two Design

Yep. After pondering and not coming up with anything, I figured there was some fancy math algorithm here, so I went to the AoC Reddit for the briefest hint I could find. The first comment on the first post I saw was all I needed.

Turns out: Nope! No fancy math, just logical thinking. [User cacaloki said](https://www.reddit.com/r/adventofcode/comments/rg5anc/2021_day_14_part_2_need_algorithm_help/hoi3w0w/):

> Create a table of pairs & occurences to begin with, and for each step, I update table with all the new pairs it would create.

After I pondered some more, the light bulb went on: Since we don't need to know the actual final polymer (only the element counts), **the order of the pairs doesn't matter**. This will let us turn an insertion problem into a counting problem.

1. Use sliding windows to create the list of pairs from the original polymer template.
1. Create a map to hold a count of each pair; set the first list to a count of 1.
1. For each pair `{a, b}` in the map,
   1. Look up `c = {a, b}` from the rules.
   1. This step will create `count` number of new `{a, c}` pairs, and `count` number of new `{c, b}` pairs.
   1. Update the map with the added counts.
1. Do the previous step N times.
1. At the end, count both elements in all the pairs in the map.
   1. We have to divide each element's `count` by 2 (it will appear in two pairs).
   1. **AND** we have to account for the first and last element of the original polymer template, which will only appear in one pair.
1. We should be able to check this against the initial 4 steps given in the puzzle example, to know if we're on the right track and have it implemented properly.
