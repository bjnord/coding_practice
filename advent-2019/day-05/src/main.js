'use strict';
const intcode = require('../src/intcode');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const program = input.trim().split(/,/).map((str) => Number(str));

// PART 1
console.log('[Part One: Enter ID of system to test (1):]');
intcode.run(program, true);
console.log('[Part One: Finished (last value should be 16489636)');
console.log('');
