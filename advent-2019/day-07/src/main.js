'use strict';
const ampSet = require('../src/amp_set');
const permutator = require('../src/permutator');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const program = input.trim().split(/,/).map((str) => Number(str));

// PART 1
const permutations = Array.from(permutator.permute([0, 1, 2, 3, 4], 5));
const signal = permutations
  .map((p) => ampSet.run(program, p))
  .reduce((max, s) => Math.max(s, max), 0);
console.log('part 1: expected answer is:   398674');
console.log(`part 1: highest signal value: ${signal}`);
console.log('');
