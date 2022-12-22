'use strict';
const gps = require('../src/gps');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const notes = gps.parse(input);

// PART 1
gps.followNotes(notes);
console.log('part 1: expected answer:                1');
console.log(`part 1: final password:                 ${gps.password(notes)}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
