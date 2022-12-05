'use strict';
const supplies = require('../src/supplies');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const steps = supplies.parseSteps(input);

// PART 1
const crates = supplies.parseCrates(input);
const tops = supplies.moveCrates(crates, steps);
console.log('part 1: expected answer:                HBTMTBSDC');
console.log(`part 1: actual answer:                  ${tops}`);
console.log('');

// PART 2
const multiCrates = supplies.parseCrates(input);
const multiTops = supplies.multiMoveCrates(multiCrates, steps);
console.log('part 2: expected answer:                PQTJRSHWS');
console.log(`part 2: actual answer:                  ${multiTops}`);
console.log('');
