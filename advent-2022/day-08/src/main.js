'use strict';
const forest = require('../src/forest');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const grid = forest.parse(input);

// PART 1
const answer1 = forest.nVisible(grid);
console.log('part 1: expected answer:         1816');
console.log(`part 1: number of visible trees: ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:         1');
console.log(`part 2: actual answer:           ${answer2}`);
console.log('');
