'use strict';
const food = require('../src/food');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const sections = food.parse(input);
const elfCalories = sections.map((items) => {
  return items.reduce((acc, cal) => acc + cal);
});
const maxElfCalories = Math.max(...elfCalories);
console.log('part 1: expected answer:                64929');
console.log(`part 1: calories of elf having most:    ${maxElfCalories}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                376203951569712');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
