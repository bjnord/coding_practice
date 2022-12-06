'use strict';
const comm = require('../src/comm');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8').trim();

// PART 1
const answer1 = comm.firstMarker(input);
console.log('part 1: expected answer:                1816');
console.log(`part 1: actual answer:                  ${answer1}`);
console.log('');

// PART 2
const answer2 = comm.firstMessageMarker(input);
console.log('part 2: expected answer:                2625');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
