# Synacor Challenge

implemented by Brent J. Nordquist using Ruby v2.5.8

you can read the first two sections spoiler-free, if

## Architecture

- code #1 is right in the `arch-spec.txt` file
- architecture description was unclear in places, at first
  - turns out operations like SET POP ADD IN only store to registers
    - WMEM is the only operation that writes to memory
  - the main memory has to hold 16-bit values (for 32768..32775 registers)
    - but these are only found in the loaded program (challenge.bin)
    - once the program is running, WMEM will only write 15-bit number values
  - CALL "write [...] to the stack" should really say "push"

## Building the Machine

- implementation was straightforward
  - one bug with OUT instruction coming from register (stupid mistake)
    - self-test can't catch this; output was weird, until I used `od` and saw NULs
- code #2 is printed once you implement HALT, OUT, NOOP as suggested
- code #3 is printed once the machine passes all self-tests

## Text Adventure

**SPOILERS FROM THIS POINT ON!**

- code #4 is found by doing `use tablet`
- code #5 is observed when walking between two rooms in the maze
