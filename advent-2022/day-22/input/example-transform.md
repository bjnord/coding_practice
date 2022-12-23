# [2022 Day 22 Part 2] Improved example input working with hardcoded coordinates

by [Reddit user blaumeise20](https://www.reddit.com/user/blaumeise20)

[permalink](https://www.reddit.com/r/adventofcode/comments/zst7z3/2022_day_22_part_2_improved_example_input_working/)

I was talking to a friend who didn't solve today's puzzle yet, and we talked about the example input not matching the real input structure. Then I thought "Why not just transform the example input to have the same structure as the real one?" Here it is:

[example-transform.txt](example-transform.txt)

You should be able to take this input (I tried it) and run it with solutions that have the coordinate mapping hardcoded (don't forget to change the chunk size from 50 to 4).

EDIT: I made a stupid mistake while transforming the input, as pointed out by a few comments. Updated the input above. Now I figured out my own code doesn't work on it.

fenrock369 says:

> the score for the test input is 10006, final position (0,9), facing West (2)

Kerma-Whore says:

> For the current input (I think it was edited) I get 10006 for part 2 and 10012 for part 1.
