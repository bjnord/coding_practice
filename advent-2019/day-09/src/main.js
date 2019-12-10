'use strict';
const intcode = require('../src/intcode');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const programStr = input.trim().split(/,/);

// PART 1
const program = programStr.map((str) => Number(str));
console.log('[Part One: Enter BOOST test mode value (1):]');
intcode.run(program);
console.log('[Part One: Finished (output value should be 2870072642)');
console.log('');
