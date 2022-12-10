'use strict';
const processor = require('../src/processor');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const program = processor.parse(input);

// PART 1
const ss = processor.signalStrengths(program);
const ssSum = ss.reduce((sum, s) => sum + s, 0);
console.log('part 1: expected answer:                14540');
console.log(`part 1: sum of six signal strengths:    ${ssSum}`);
console.log('');

// PART 2
const pixels = processor.renderPixels(program);
console.log('part 2: expected answer:                EHZFZHCZ');
console.log('part 2: actual answer:');
processor.dumpPixels(pixels);
console.log('');
