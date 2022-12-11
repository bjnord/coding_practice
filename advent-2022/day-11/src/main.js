'use strict';
const monkey = require('../src/monkey');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const monkeys = monkey.parse(input);

// PART 1
for (let i = 0; i < 20; i++) {
  monkey.runRound(monkeys);
}
const ans1 = monkey.mostActive(monkeys);
console.log('part 1: expected answer:                      117624');
console.log(`part 1: level of monkey business (20 rounds): ${ans1[0] * ans1[1]}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                      1');
console.log(`part 2: actual answer:                        ${answer2}`);
console.log('');
