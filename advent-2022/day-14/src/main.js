'use strict';
const regolith = require('../src/regolith');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const map = regolith.makeMap(regolith.parse(input));

// PART 1
const answer1 = regolith.totalSand(map);
console.log('part 1: expected answer:                 1');
console.log(`part 1: units of sand that come to rest: ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                 1');
console.log(`part 2: actual answer:                   ${answer2}`);
console.log('');
