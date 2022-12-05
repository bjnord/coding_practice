'use strict';
const supplies = require('../src/supplies');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const crates = supplies.parseCrates(input);
const steps = supplies.parseSteps(input);

// PART 1
const tops = supplies.moveCrates(crates, steps);
console.log('part 1: expected answer:                HBTMTBSDC');
console.log(`part 1: actual answer:                  ${tops}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
