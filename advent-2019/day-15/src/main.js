'use strict';
const Droid = require('../src/droid');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const droid = new Droid(input);
console.log('part 1: expected answer:                 232');
droid.run();
console.log(`part 1: length of path to oxygen system: ${droid.oxygenSystemDistance}`);
console.log('');

// PART 2
console.log('part 2: expected answer:                  320');
const length = droid.longestPathLengthFrom(droid.oxygenSystemPosition);
console.log(`part 2: minutes to fill maze with oxygen: ${length}`);
