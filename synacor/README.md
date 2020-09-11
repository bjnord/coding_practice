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

[so when the machine is implemented to pass all self-tests, R7=0, and you are teleported to Synacor HQ to be able to read this book]

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

the machine can be started with a non-0 value in R7, if the self-test is defeated:
- change the `0x07` JT opcode value in `0209 JT   R7 0x0445` to `0x08`, a `JF` opcode

teleporting then says:

> A strange, electronic voice is projected into your mind:
>
>   "Unusual setting detected!  Starting confirmation process!  Estimated time to completion: 1 billion years."
