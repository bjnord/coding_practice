'use strict';
const food = require('../src/food');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const tbpThing = food.parse(input);
const answer1 = 0;
console.log('part 1: expected answer:                5937');
console.log(`part 1: actual answer:                  ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                376203951569712');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
