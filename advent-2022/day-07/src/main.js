'use strict';
const device = require('../src/device');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const tree = device.parse(input);

// PART 1
const entries = device.calculateSizes(tree);
const totalSize = entries.map((entry) => entry.size)
  .filter((size) => size <= 100000)
  .reduce((total, size) => total + size, 0);
console.log('part 1: expected answer:                  1501149');
console.log(`part 1: total size of <=100k directories: ${totalSize}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                  1');
console.log(`part 2: actual answer:                    ${answer2}`);
console.log('');
