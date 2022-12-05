'use strict';
const supplies = require('../src/supplies');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const steps = supplies.parseSteps(input);

// PART 1
const stacks = supplies.parseStacks(input);
const tops = supplies.moveCrates(stacks, steps);
console.log('part 1: expected answer:                HBTMTBSDC');
console.log(`part 1: actual answer:                  ${tops}`);
console.log('');

// PART 2
const stacks2 = supplies.parseStacks(input);
const tops2 = supplies.multiMoveCrates(stacks2, steps);
console.log('part 2: expected answer:                PQTJRSHWS');
console.log(`part 2: actual answer:                  ${tops2}`);
console.log('');
