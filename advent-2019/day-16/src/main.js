'use strict';
const fft = require('../src/fft');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const iList = input.trim().split('').map((i) => Number(i));

// PART 1
const oList = fft.phases(iList, 100);
const oStr = oList.slice(0, 8).join('');
console.log('part 1: expected answer:                     78009100');
console.log(`part 1: first 8 digits after 100 FFT phases: ${oStr}`);
console.log('');
