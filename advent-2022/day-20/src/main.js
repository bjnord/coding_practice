'use strict';
const grove = require('../src/grove');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const numbers = grove.parse(input);

// PART 1
const state = grove.state(numbers);
grove.doMoves(state);
const answer1 = grove.coordinates(state)
  .reduce((sum, coord) => sum + coord, 0);
console.log('part 1: expected answer:                **TOOLOW** 1242');
console.log(`part 1: sum of grove coordinates:       ${answer1}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
