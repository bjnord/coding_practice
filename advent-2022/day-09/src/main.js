'use strict';
const rope = require('../src/rope');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const motions = rope.parse(input);

// PART 1
const answer1 = rope.followMotions(motions, 2, null);
console.log('part 1: expected answer:                6236');
console.log(`part 1: positions 2-knot tail visited:  ${answer1}`);
console.log('');

// PART 2
const answer2 = rope.followMotions(motions, 10, null);
console.log('part 2: expected answer:                2449');
console.log(`part 2: positions 10-knot tail visited: ${answer2}`);
console.log('');
