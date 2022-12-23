'use strict';
const gps = require('../src/gps');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

if (process.argv[process.argv.length - 1] === '--dump') {
  const cubicDump = (process.argv[process.argv.length - 2] === '--cubic');
  const exampleInput = fs.readFileSync('input/example.txt', 'utf8');
  const exampleNotes = gps.parse(exampleInput);
  gps.followNotes(exampleNotes, cubicDump);
  console.log(gps.renderTrail(exampleNotes));
  process.exit(0);
}

// PART 1
let notes = gps.parse(input);
gps.followNotes(notes);
console.log('part 1: expected answer:       149138');
console.log(`part 1: final password:        ${gps.password(notes)}`);
console.log('');

// PART 2
notes = gps.parse(input);
gps.followNotes(notes, true);
console.log('part 2: expected answer:       ** TOOLOW: 148329, TOOHIGH: 154156 **');
console.log(`part 2: final password (cube): ${gps.password(notes)}`);
console.log('');
