'use strict';
const intcode = require('../../shared/src/intcode');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const programStr = input.trim().split(/,/);
const program = programStr.map((str) => Number(str));

// PART 1
const iProgram = program.slice();
iProgram[1] = 12;
iProgram[2] = 2;
intcode.run(iProgram);
console.log('part 1: expected answer is:  3850704');
console.log(`part 1: value at position 0: ${iProgram[0]}`);
console.log('');

// PART 2
console.log('part 2: expected answer is:           6718');
for (let noun = 0; noun < 100; noun++) {
  for (let verb = 0; verb < 100; verb++) {
    const iProgram = program.slice();
    iProgram[1] = noun;
    iProgram[2] = verb;
    intcode.run(iProgram);
    if (iProgram[0] === 19690720) {
      console.log(`part 2: values that produce 19690720: noun=${noun} verb=${verb}`);
      console.log(`part 2: answer to submit:             ${noun*100+verb}`);
    }
  }
}
