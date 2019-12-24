'use strict';
const bugs = require('../src/bugs');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const inputLines = input.trim().split(/\n/);

// PART 1
const initialState = bugs.parse(inputLines);
const finalState = bugs.iterate(initialState);
console.debug('part 1: repeated state:');
bugs.format(finalState).forEach((line) => console.debug('        '+line));
console.log('part 1: expected answer:      13500447');
console.log(`part 1: biodiversity rating:  ${finalState}`);
console.log('');
