'use strict';
const camp = require('../src/camp');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const assignmentPairs = camp.parse(input);

// PART 1
const containedPairs = assignmentPairs.filter((pair) => {
  return camp.fullContainment(pair);
});
console.log('part 1: expected answer:             526');
console.log(`part 1: pairs with full containment: ${containedPairs.length}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:             1');
console.log(`part 2: pairs which overlap at all:  ${answer2}`);
console.log('');
