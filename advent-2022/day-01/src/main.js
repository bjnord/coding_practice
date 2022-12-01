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
console.log('part 1: expected answer:                 64929');
console.log(`part 1: calories of elf having most:     ${maxElfCalories}`);
console.log('');

// PART 2
const topElfCalories = elfCalories.sort((a, b) => b - a).slice(0, 3);
const maxElfCalories3 = topElfCalories.reduce((acc, cal) => acc + cal);
console.log('part 2: expected answer:                 193697');
console.log(`part 2: calories of 3 elves having most: ${maxElfCalories3}`);
console.log('');
