'use strict';
const rocket = require('../src/rocket');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const moduleMasses = input.trim().split(/\s+/);
const summer = ((acc, i) => acc + i);

// PART 1
const total = moduleMasses
  .map((mass) => rocket.mass2fuel(mass))
  .reduce(summer);
console.log('part 1: expected answer is:          3405721');
console.log(`part 1: sum of fuel requirements is: ${total}`);
console.log('');

// PART 2
const fullTotal = moduleMasses
  .map((mass) => rocket.mass2fullfuel(mass))
  .reduce(summer);
console.log('part 2: expected answer is:          5105716');
console.log(`part 2: sum of fuel requirements is: ${fullTotal}`);
