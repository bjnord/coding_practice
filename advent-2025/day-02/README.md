# Day 2: Gift Shop

## Part One

You get inside and take the elevator to its only other stop: the gift
shop. "Thank you for visiting the North Pole!" gleefully exclaims a
nearby sign. You aren't sure who is even allowed to visit the North
Pole, but you know you can access the lobby through here, and from there
you can access the rest of the North Pole base.

As you make your way through the surprisingly extensive selection, one
of the clerks recognizes you and asks for your help.

As it turns out, one of the younger Elves was playing on a gift shop
computer and managed to add a whole bunch of invalid product IDs to
their gift shop database! Surely, it would be no trouble for you to
identify the invalid product IDs for them, right?

They've even checked most of the product ID ranges already; they only
have a few product ID ranges (your puzzle input) that you'll need to
check. For example:

```
    11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
    1698522-1698528,446443-446449,38593856-38593862,565653-565659,
    824824821-824824827,2121212118-2121212124
```

(The ID ranges are wrapped here for legibility; in your input, they
appear on a single long line.)

The ranges are separated by commas (`,`); each range gives its **first
ID** and **last ID** separated by a dash (`-`).

Since the young Elf was just doing silly patterns, you can find the
**invalid IDs** by looking for any ID which is made only of some sequence
of digits repeated twice. So, `55` (`5` twice), `6464` (`64` twice), and
`123123` (`123` twice) would all be invalid IDs.

None of the numbers have leading zeroes; `0101` isn't an ID at all.
(`101` is a **valid** ID that you would ignore.)

Your job is to find all of the invalid IDs that appear in the given
ranges. In the above example:

-   `11-22` has two invalid IDs, `11` and `22`.
-   `95-115` has one invalid ID, `99`.
-   `998-1012` has one invalid ID, `1010`.
-   `1188511880-1188511890` has one invalid ID, `1188511885`.
-   `222220-222224` has one invalid ID, `222222`.
-   `1698522-1698528` contains no invalid IDs.
-   `446443-446449` has one invalid ID, `446446`.
-   `38593856-38593862` has one invalid ID, `38593859`.
-   The rest of the ranges contain no invalid IDs.

Adding up all the invalid IDs in this example produces `1227775554`.

**What do you get if you add up all of the invalid IDs?**

## Part Two

The clerk quickly discovers that there are still invalid IDs in the
ranges in your list. Maybe the young Elf was doing other silly patterns
as well?

Now, an ID is invalid if it is made only of some sequence of digits
repeated **at least** twice. So, `12341234` (`1234` two times),
`123123123` (`123` three times), `1212121212` (`12` five times), and
`1111111` (`1` seven times) are all invalid IDs.

From the same example as before:

-   `11-22` still has two invalid IDs, `11` and `22`.
-   `95-115` now has two invalid IDs, `99` and `111`.
-   `998-1012` now has two invalid IDs, `999` and `1010`.
-   `1188511880-1188511890` still has one invalid ID, `1188511885`.
-   `222220-222224` still has one invalid ID, `222222`.
-   `1698522-1698528` still contains no invalid IDs.
-   `446443-446449` still has one invalid ID, `446446`.
-   `38593856-38593862` still has one invalid ID, `38593859`.
-   `565653-565659` now has one invalid ID, `565656`.
-   `824824821-824824827` now has one invalid ID, `824824824`.
-   `2121212118-2121212124` now has one invalid ID, `2121212121`.

Adding up all the invalid IDs in this example produces `4174379265`.

**What do you get if you add up all of the invalid IDs using these new
rules?**

### Part Two Design

> **Spoilers ahead!**

My initial design (testing each product ID in each range) worked, but took several seconds to run each part. Later in the day I was mulling what optimization approach to take (benchmarking, heatmaps, parallelism, etc.) when suddenly I realized there was a much simpler way to approach the problem.

The revised design constructs all possible doubled or repeated product IDs from a substring of the range values, and then sees which ones actually fall into the range. For example: Given the range 1000-2900, you only need to try double-10 through double-29, as well as all 1s and all 2s. There are a few other things to be handled (like ranges where the lo and hi value have a different number of digits).

After the code was done I fired up [Benchee](https://github.com/bencheeorg/benchee) and whoa, Nellie:

```
Operating System: Linux
CPU Information: AMD EPYC 7571
Number of Available Cores: 4
Available memory: 15.45 GB
Elixir 1.19.4
Erlang 27.3.4.6
JIT enabled: true

Name                  ips        average  deviation         median         99th %
fast part 1       19.43 K      0.00005 s    ±34.63%      0.00005 s      0.00010 s
slow part 1     0.00080 K         1.26 s     ±2.78%         1.25 s         1.31 s

Comparison:
fast part 1       19.43 K
slow part 1     0.00080 K - 24430.89x slower +1.26 s

Name                  ips        average  deviation         median         99th %
fast part 2       11.97 K      0.00008 s    ±23.63%      0.00008 s      0.00014 s
slow part 2     0.00028 K         3.55 s     ±1.21%         3.54 s         3.61 s

Comparison:
fast part 2       11.97 K
slow part 2     0.00028 K - 42520.65x slower +3.55 s
```
