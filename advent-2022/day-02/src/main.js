'use strict';
const roshambo = require('../src/roshambo');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const rounds = roshambo.parse(input);
console.log('part 1: expected answer:                12645');
console.log(`part 1: actual answer:                  ${roshambo.scoreRounds(rounds)}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
