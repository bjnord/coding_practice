'use strict';
const rucksack = require('../src/rucksack');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const rucksacks = rucksack.parse(input);

// PART 1
const items = rucksacks.map((ruck) => rucksack.commonItem(ruck));
const sum = items.reduce((sum, item) => sum + rucksack.itemPriority(item), 0);
console.log('part 1: expected answer:                7889');
console.log(`part 1: actual answer:                  ${sum}`);
console.log('');

// PART 2
const items3 = rucksack.commonItems3(rucksacks);
const sum3 = items3.reduce((sum, item) => sum + rucksack.itemPriority(item), 0);
console.log('part 2: expected answer:                2825');
console.log(`part 2: actual answer:                  ${sum3}`);
console.log('');
