'use strict';
const beacon = require('../src/beacon');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const pairs = beacon.parse(input);

// PART 1
const answer1 = beacon.countNotAt(pairs, 2000000);
console.log('part 1: expected answer:                     5832528');
console.log(`part 1: beaconless positions at row 2000000: ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                     1');
console.log(`part 2: actual answer:                       ${answer2}`);
console.log('');
