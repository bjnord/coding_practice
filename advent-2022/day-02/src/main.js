'use strict';
const roshambo = require('../src/roshambo');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const rounds = roshambo.parse(input);

// PART 1
console.log('part 1: expected answer:              12645');
console.log(`part 1: total score with strategy 1:  ${roshambo.scoreRounds(rounds)}`);
console.log('');

// PART 2
console.log('part 2: expected answer:              11756');
console.log(`part 2: total score with strategy 2:  ${roshambo.scoreRounds2(rounds)}`);
console.log('');
