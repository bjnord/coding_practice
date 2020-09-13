# Synacor Challenge

implemented by Brent J. Nordquist using Ruby v2.5.8

you can read the first two sections spoiler-free, but starting with the "Text Adventure" section, there are spoilers for the puzzles

## Architecture

- code #1 is given in the `arch-spec.txt` file
- architecture description was unclear in places, at first
  - operations like `SET` `POP` `ADD` and `IN` _etc._ only store to registers
    - `WMEM` is the only operation that writes to memory
  - the main memory has to hold 16-bit values (for 32768..32775 registers)
    - but these are only found in the loaded program (`challenge.bin`)
    - once the program is running, `WMEM` will only write 15-bit number values
  - `CALL` "write [...] to the stack" should really say "push"

### Building the Machine

- implementation was straightforward
  - one bug with `OUT` instruction coming from register (stupid mistake)
    - self-test can't catch this; output was weird, until I used `od` and saw `NUL` characters
- run the challenge program on the machine with `bin/challenge challenge.bin [input-file]`
- code #2 is printed once you implement `HALT` `OUT` and `NOOP` as suggested
- code #3 is printed once the machine passes all self-tests

---

**SPOILERS FROM THIS POINT ON!**

---

## Text Adventure

see the dungeon maps in the `doc/maps/` directory (I used [Mermaid](https://mermaid-js.github.io/mermaid/))

my machine implementation can be run using scripted input (2nd argument to `bin/challenge`)
- run `bin/dungeon` for the first mode (`R7=0`), teleporting to Synacor HQ
  - `dungeon.txt` is the script for this mode
- run `bin/teleport` for the second mode (`R7>0`), teleporting to the rainy beach
  - `teleport.txt` is the script for this mode

### Dungeon (first mode)

- code #4 is found by doing `use tablet`
  - tablet is in Foothills where you start the game
- then you need to
  - get the lantern (room in Moss cavern)
  - get the can (room in Maze)
  - do `use can` to fill the latern with oil and make it happy
- code #5 is observed when walking between two rooms in the maze
- you need a lit lantern (`use lantern`) to navigate the Dark passage

### Coin Puzzle (Ruins)

- equation: `_ + _ * _^2 + _^3 - _ = 399`
- coin values:
  - red = 2
  - blue = 9
  - shiny = 5
  - concave = 7
  - corroded = 3
- so insert coins in this order:
  - blue, red, shiny, concave, corroded
- code #6 is revealed after solving the coin puzzle and teleporting to Synacor HQ (in first mode `R7=0`)

### Teleporter Puzzle

contents of the strange book (`look strange book`):

> The cover of this book subtly swirls with colors.  It is titled "A Brief Introduction to Interdimensional Physics".  It reads:
>
> Recent advances in interdimensional physics have produced fascinating
> predictions about the fundamentals of our universe!  For example,
> interdimensional physics seems to predict that the universe is, at its root, a
> purely mathematical construct, and that all events are caused by the
> interactions between eight pockets of energy called "registers".
> Furthermore, it seems that while the lower registers primarily control mundane
> things like sound and light, the highest register (the so-called "eighth
> register") is used to control interdimensional events such as teleportation.
>
> A hypothetical such teleportation device would need to have have exactly two
> destinations.  One destination would be used when the eighth register is at its
> minimum energy level - this would be the default operation assuming the user
> has no way to control the eighth register.  In this situation, the teleporter
> should send the user to a preconfigured safe location as a default.

[so when the machine is implemented to pass all self-tests, `R7=0`, and you are teleported to Synacor HQ to be able to read this book]

> The second destination, however, is predicted to require a very specific
> energy level in the eighth register.  The teleporter must take great care to
> confirm that this energy level is exactly correct before teleporting its user!
> If it is even slightly off, the user would (probably) arrive at the correct
> location, but would briefly experience anomalies in the fabric of reality
> itself - this is, of course, not recommended.  Any teleporter would need to test
> the energy level in the eighth register and abort teleportation if it is not
> exactly correct.
>
> This required precision implies that the confirmation mechanism would be very
> computationally expensive.  While this would likely not be an issue for
> large-scale teleporters, a hypothetical hand-held teleporter would take billions
> of years to compute the result and confirm that the eighth register is correct.

[so this is going to be like Advent of Code 2018 Day 19]

> If you find yourself trapped in an alternate dimension with nothing but a
> hand-held teleporter, you will need to extract the confirmation algorithm,
> reimplement it on more powerful hardware, and optimize it.  This should, at the
> very least, allow you to determine the value of the eighth register which would
> have been accepted by the teleporter's confirmation mechanism.
>
> Then, set the eighth register to this value, activate the teleporter, and
> bypass the confirmation mechanism.  If the eighth register is set correctly, no
> anomalies should be experienced, but beware - if it is set incorrectly, the
> now-bypassed confirmation mechanism will not protect you!
>
> Of course, since teleportation is impossible, this is all totally ridiculous.

the machine can be started with `R7>0`, if the self-test is defeated:
- change the `0x07` JT opcode value in `0209 JT   R7 0x0445` to be `0x08`, the `JF` opcode

teleporting then says:

> A strange, electronic voice is projected into your mind:
>
>   "Unusual setting detected!  Starting confirmation process!  Estimated time to completion: 1 billion years."

#### Optimization Approach

I created a simple disassembler to dump the whole program

- there's a huge chunk of data at the bottom of the program
  - all 15 bits get used most of the time; some form of compression?
- it looks like `CALL 0x05b2` (with `R0` `R1` and `R2` set) might be the message output routine

I let the program run a while in `R7>0` mode, dumping each instruction executed, and then counted to find the "hot spots":

- `PC 178b-17b3` were hit about 300k times
- `PC 084d-0864` were hit about 50k times
- `PC 06c2-06df` were hit about 25k times
- `PC 05c8-05e0` were hit about 10k times

#### Hottest Section

```
178b JT   R0 0x1793
178e ADD  R0 R1 0x0001
1792 RET

1793 JT   R1 0x17a0
1796 ADD  R0 R0 0x7fff
179a SET  R1 R7
179d CALL 0x178b
179f RET

17a0 PUSH R0
17a2 ADD  R1 R1 0x7fff
17a6 CALL 0x178b
17a8 SET  R1 R0
17ab POP  R0
17ad ADD  R0 R0 0x7fff
17b1 CALL 0x178b
17b3 RET
```

The entry points here are `178b` `1793` and `17a0`, and only `178b` is called from the outside:

```
156b SET  R0 0x0004
156e SET  R1 0x0001
1571 CALL 0x178b
1573 EQ   R1 R0 0x0006
1577 JF   R1 0x15cb
157a PUSH R0
157c PUSH R1
157e PUSH R2
1580 SET  R0 0x7156
1583 SET  R1 0x05fb
1586 ADD  R2 0x3372 0x0a8a
158a CALL 0x05b2
...
15cb PUSH R0
15cd PUSH R1
15cf PUSH R2
15d1 SET  R0 0x72d8
15d4 SET  R1 0x05fb
15d7 ADD  R2 0x154f 0x4291
15db CALL 0x05b2
```

#### Optimized Function

- the `178b` routine wants inputs `R0` and `R1` (which are always the same) and `R7`
  - so we only have to try 32767 values of `R7` to find the answer
  - I can't visualize this as a single function (what is this 3-part routine trying to calculate?)
- the caller of the `178b` routine is checking to see if `R0=6`
  - the caller immediately overwrites `R1` after return
    - so it clearly doesn't care what `R1` was returned
- I initially tried to simulate it directly in Ruby with recursion
  - but it blows the call stack
- I considered working backwards from the desired result
  - but this doesn't solve the exponential nature of the code
- then I remembered **tail recursion** from Advent of Code 2018 (Elixir)
  - the first section can return its result directly
  - the second section can call itself tail-recursively
  - unfortunately the first call of the third section can't be tail-recursive
    - but at least the second one can be
  - tail recursion [has to be explicitly enabled in Ruby](https://harfangk.github.io/2017/01/01/how-to-enable-tail-call-recursion-in-ruby.html) (and is only supported in some Ruby runtimes, fortunately including MRI)
- I created a cache, on the theory that at least some calls will be duplicates
  - watching the output, it looks like 30-40% of second- and third-section calls come from cache
- I also [bumped up the Ruby (and Unix-level) stack size](https://stackoverflow.com/a/30816311/291754)
- the resulting program `bin/try-r7` ran for an hour or so (good enough), and produced this!
```
        with R7=25734 f([4, 1])=[6, 5]
        entries=91269 misses=91300(60.9%) hits=58512(39.1%)
        WINNER
```

### Tropical Island (second mode)

code #7 is drawn in the sand on the beach, immediately after teleporting to the island (in second mode `R7>0`)

typos here ("embankment" should be "embankments" plural; "come toegher" should be "come together"):
```
== Tropical Island ==
The embankment of the cove come toegher here to your east and west.
```

### Vault Puzzle

The map of my vault grid:

```
+--------+--------+--------+--------+
|        |        |        | Vault  |
|   *    |   8    |   -    |  "30"  |
|        |        |        |        |
+--------+--------+--------+--------+
|        |        |        |        |
|   4    |   *    |   11   |   *    |
|        |        |        |        |
+--------+--------+--------+--------+
|        |        |        |        |
|   +    |   4    |   -    |   18   |
|        |        |        |        |
+--------+--------+--------+--------+
| Antech |        |        |        |
|  "22"  |   -    |   9    |   *    |
|    orb |        |        |        |
+--------+--------+--------+--------+
```

No matter how you walk from the Antechamber to the Vault Door, you get numbers alternating with operations, like an equation.

The journal reads:

> Day 1: We have reached what seems to be the final in a series of puzzles guarding an ancient treasure.  I suspect most adventurers give up long before this point, but we're so close!  We must press on!
>
> Day 1: P.S.: It's a good thing the island is tropical.  We should have food for weeks!
>
> Day 2: The vault appears to be sealed by a mysterious force - the door won't budge an inch.  We don't have the resources to blow it open, and I wouldn't risk damaging the contents even if we did.  We'll have to figure out the lock mechanism.
>
> Day 3: The door to the vault has a number carved into it.  Each room leading up to the vault has more numbers or symbols embedded in mosaics in the floors.  We even found a strange glass orb in the antechamber on a pedestal itself labeled with a number.  What could they mean?
>
> Day 5: We finally built up the courage to touch the strange orb in the antechamber.  It flashes colors as we carry it from room to room, and sometimes the symbols in the rooms flash colors as well.  It simply evaporates if we try to leave with it, but another appears on the pedestal in the antechamber shortly thereafter.  It also seems to do this even when we return with it to the antechamber from the other rooms.
>
> Day 8: When the orb is carried to the vault door, the numbers on the door flash black, and then the orb evaporates.  Did we do something wrong?  Doesn't the door like us?  We also found a small hourglass near the door, endlessly running.  Is it waiting for something?
>
> Day 13: Some of my crew swear the orb actually gets heaver or lighter as they walk around with it.  Is that even possible?  They say that if they walk through certain rooms repeatedly, they feel it getting lighter and lighter, but it eventually just evaporates and a new one appears as usual.
>
> Day 21: Now I can feel the orb changing weight as I walk around.  It depends on the area - the change is very subtle in some places, but certainly more noticeable in others, especially when I walk into a room with a larger number or out of a room marked '\*'.  Perhaps we can actually control the weight of this mysterious orb?
>
> Day 34: One of the crewmembers was wandering the rooms today and claimed that the numbers on the door flashed white as he approached!  He said the door still didn't open, but he noticed that the hourglass had run out and flashed black.  When we went to check on it, it was still running like it always does.  Perhaps he is going mad?  If not, which do we need to appease: the door or the hourglass?  Both?
>
> Day 55: The fireflies are getting suspicious.  One of them looked at me funny today and then flew off.  I think I saw another one blinking a little faster than usual.  Or was it a little slower?  We are getting better at controlling the weight of the orb, and we think that's what the numbers are all about.  The orb starts at the weight labeled on the pedestal, and goes down as we leave a room marked '-', up as we leave a room marked '+', and up even more as we leave a room marked '\*'.  Entering rooms with larger numbers has a greater effect.
>
> Day 89: Every once in a great while, one of the crewmembers has the same story: that the door flashes white, the hourglass had already run out, it flashes black, and the orb evaporates.  Are we too slow?  We can't seem to find a way to make the orb's weight match what the door wants before the hourglass runs out.  If only we could find a shorter route through the rooms...
>
> Day 144: We are abandoning the mission.  None of us can work out the solution to the puzzle.  I will leave this journal here to help future adventurers, though I am not sure what help it will give.  Good luck!

#### Solution Approaches

- some experimentation confirms my guess
  - the movement operations need to transform 22 to 30
  - there's no operator precedence (5 + 4 * 2 = 18, not 13)
- approach #1: pencil-and-paper
  - I found two paths that made the vault number flash white
  - but the hourglass had expired; 14 moves is apparently too much
- approach #2: arithmetic
  - we need to get from 22 to at least 41 (to account for the `- 11 * 1` at the end)
  - the only `+` is right next to the antechamber, and we can only add 4 each time
  - so the fastest way to get above 41 seems to be `* 4`
    - and the only way to do that is to do `+ 4` first
  - `+ 4 * 4` leaves me at 104 in 4 moves
  - then I can have as many `- 4`, `- 9`, `- 11`, and `- 18` operations as I want
    - as long as I do one `- 11` or `- 18` at the end, followed by `* 1` (or `- 1` for the 11 case)
  - so we need solutions for: `104 - 4*A - 9*B - 11*C - 1*D = 30`
    - where `D` can be `1` if `C > 0`
    - and where we want `A + B + C` to be minimized, and no more than 3 total
      - 4 initial moves, 6 mid moves, 2 final moves = 12 total moves
    - and where a double `B` can be replaced with a `- 18` instead (saving moves)
  - sadly, none of these solutions are shorter than 14 moves
- approach #3: recursively walk the maze (with maximum 12 moves)
  - for the record, I think subconsciously I left this approach for last
    - because of the battle scars from Advent of Code maze walking algorithms
    - for which recursion didn't work or took too long etc.
  - but this one was pretty easy, and it did work; there is one solution in 12 moves:
    - north, east, east, north, west, south, east, east, west, north, north, east
    - `22 + 4 - 11 * 4 - 18 - 11 - 1 = 30`

#### Vault Door

typo here ("hour hands" should be "your hands"):
```
As you approach the vault door, the number on the vault door flashes white!  The hourglass is still running!  It flashes white!  You hear a click from the vault door.  The orb evaporates out of hour hands.
```

#### Vault

code #8 is printed on your forehead in charcoal

- use the mirror found in the vault, but of course, you're seeing it in a mirror, so... (this made me laugh!)
