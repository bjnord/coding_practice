'use strict';
const yell = require('../src/yell');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const monkeys = yell.parse(input);

// PART 1
const answer1 = yell.rootMonkeyNumber(monkeys);
console.log('part 1: expected answer:                331120084396440');
console.log(`part 1: number that root monkey yells:  ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
