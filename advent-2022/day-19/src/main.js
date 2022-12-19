'use strict';
const Blueprint = require('../src/blueprint');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const blueprints = Blueprint.parse(input);

// PART 1
const answer1 = 0;
console.log('part 1: expected answer:                1');
console.log(`part 1: actual answer:                  ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
