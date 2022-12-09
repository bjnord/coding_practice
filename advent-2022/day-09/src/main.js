'use strict';
const rope = require('../src/rope');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const motions = rope.parse(input);

// PART 1
const answer1 = rope.followMotions(motions);
console.log('part 1: expected answer:                6236');
console.log(`part 1: positions rope tail visited:    ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
