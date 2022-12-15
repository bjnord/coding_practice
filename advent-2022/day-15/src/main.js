'use strict';
const beacon = require('../src/beacon');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const pairs = beacon.parse(input);

// PART 1
const answer1 = beacon.countNotAt(pairs, 2000000);
console.log('part 1: expected answer:                     5832528');
console.log(`part 1: beaconless positions at row 2000000: ${answer1}`);
console.log('');

// PART 2
let pos = undefined;
for (let x = 0; x <= 4000000; x++) {
  const y = beacon.findBeaconAtColumn(pairs, x, 4000000);
  if (y !== null) {
    pos = {x, y};
    break;
  }
}
const freq = pos.x * 4000000 + pos.y;
console.log('part 2: expected answer:                     13360899249595');
console.log(`part 2: tuning frequency of beacon:          ${freq}`);
console.log('');
