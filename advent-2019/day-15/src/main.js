'use strict';
const Droid = require('../src/droid');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const droid = new Droid(input);
console.log('part 1: expected answer:                 232');
try {
  droid.run();
}
catch (error) {
  console.error(error);
};
console.log(`part 1: length of path to oxygen system: ${droid.oxygenSystemDistance}`);
console.log('');
