'use strict';
const food = require('../src/food');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const sections = food.parse(input);

// PART 1
const elfCalories = food.totalCaloriesSorted(sections);
console.log('part 1: expected answer:                 64929');
console.log(`part 1: calories of elf having most:     ${elfCalories[0]}`);
console.log('');

// PART 2
const topElfCalories = elfCalories.slice(0, 3);
const maxElfCalories3 = topElfCalories.reduce((acc, cal) => acc + cal, 0);
console.log('part 2: expected answer:                 193697');
console.log(`part 2: calories of 3 elves having most: ${maxElfCalories3}`);
console.log('');
