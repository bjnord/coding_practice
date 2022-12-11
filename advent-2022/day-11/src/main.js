'use strict';
const monkey = require('../src/monkey');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
let monkeys = monkey.parse(input);
for (let i = 0; i < 20; i++) {
  monkey.runRound(monkeys, true);
}
const ans1 = monkey.mostActive(monkeys);
console.log('part 1: expected answer:                       117624');
console.log(`part 1: level of monkey business (20 rounds):  ${ans1[0] * ans1[1]}`);
console.log('');

// PART 2
monkeys = monkey.parse(input);
for (let i = 0; i < 10000; i++) {
  monkey.runRound(monkeys, false);
}
const ans2 = monkey.mostActive(monkeys);
console.log('part 2: expected answer:                       16792940265');
console.log(`part 2: level of monkey business (10k rounds): ${ans2[0] * ans2[1]}`);
console.log('');
