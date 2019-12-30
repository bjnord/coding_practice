'use strict';
const bugs = require('../src/bugs');
const nBugs = require('../src/n_fold_bugs');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const inputLines = input.trim().split(/\n/);

// PART 1
const initialState = bugs.parse(inputLines);
const finalState = bugs.iterate(initialState);
//console.debug('part 1: repeated state:');
//bugs.format(finalState).forEach((line) => console.debug('        '+line));
console.log('part 1: expected answer:      13500447');
console.log(`part 1: biodiversity rating:  ${finalState}`);
console.log('');

// PART 2
const initialLevel = {number: 0, state: nBugs.parseOne(inputLines)};
const min = 200;
nBugs.iterateMultiLevel(initialLevel, min);
const bugCount = nBugs.countMultiLevel(initialLevel);
console.log('part 2: expected answer:                 2120');
console.log(`part 2: bugs present after ${min} minutes:  ${bugCount}`);
console.log('');
