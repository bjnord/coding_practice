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

// PART 2
const offset = Number(input.slice(0, 7));
//console.log(`part 2: message offset:                          ${offset}`);
const message = fft.messageFromPhases(iList, 10000, 100, offset);
const mStr = message.join('');
console.log('part 2: expected answer:                         37717791');
console.log(`part 2: 8 digits at offset after 100 FFT phases: ${mStr}`);
