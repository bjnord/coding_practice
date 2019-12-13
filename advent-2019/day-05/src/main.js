'use strict';
const intcode = require('../../shared/src/intcode');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const programStr = input.trim().split(/,/);

// PART 1
let program = programStr.map((str) => Number(str));
console.log('[Part One: Enter ID of system to test (1):]');
intcode.run(program, true);
console.log('[Part One: Finished (last value should be 16489636)');
console.log('');

// PART 2
program = programStr.map((str) => Number(str));
console.log('[Part Two: Enter ID of system to test (5):]');
intcode.run(program, true);
console.log('[Part Two: Finished (output should be 9386583)');
console.log('');
