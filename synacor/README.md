# Synacor Challenge

implemented by Brent J. Nordquist using Ruby v2.5.8

you can read the first two sections spoiler-free, but starting with the "Text Adventure" section, there are spoilers for the puzzles

## Architecture

- code #1 is right in the `arch-spec.txt` file
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

my machine implementation can be run using scripted input (2nd argument to `bin/challenge`); see `input.txt` for the dungeon run

- code #4 is found by doing `use tablet`
- code #5 is observed when walking between two rooms in the maze

### Coin Puzzle

- equation: `_ + _ * _^2 + _^3 - _ = 399`
- red coin = 2
- blue coin = 9
- shiny coin = 5
- concave coin = 7
- corroded coin = 3
- solution: blue, red, shiny, concave, corroded

- code #6 is revealed after solving the coin puzzle and teleporting

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
