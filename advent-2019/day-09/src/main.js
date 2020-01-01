'use strict';
const intcode = require('../../shared/src/intcode');
const readline = require('readline-sync');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const programStr = input.trim().split(/,/);

// PART 1
let program = programStr.map((str) => Number(str));
console.log('[Part One: Enter BOOST test mode value (1):]');
// use destructuring to avoid lint "unused argument" errors
// h/t <https://stackoverflow.com/a/58738236/291754>
intcode.run(...[program, , , , , readline]);
console.log('[Part One: Finished (output value should be 2870072642)');
console.log('');

// PART 2
program = programStr.map((str) => Number(str));
console.log('[Part Two: Enter BOOST sensor boost mode value (2):]');
// use destructuring to avoid lint "unused argument" errors
// h/t <https://stackoverflow.com/a/58738236/291754>
intcode.run(...[program, , , , , readline]);
console.log('[Part Two: Finished (output value should be 58534)');
console.log('');
