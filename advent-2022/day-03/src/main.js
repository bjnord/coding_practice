'use strict';
const rucksack = require('../src/rucksack');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const rucksacks = rucksack.parse(input);
const priorities = rucksacks.map((ruck) => rucksack.itemPriority(rucksack.commonItem(ruck)));
const sum = priorities.reduce((sum, pri) => sum + pri);
console.log('part 1: expected answer:                7889');
console.log(`part 1: actual answer:                  ${sum}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
