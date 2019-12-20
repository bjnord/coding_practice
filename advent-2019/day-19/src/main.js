'use strict';
const TractorBeam = require('../src/tractor_beam');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const tractorBeam = new TractorBeam(input);
let size = 50;
tractorBeam.mapGrid(size, size);
console.log('part 1: expected answer:               179');
console.log(`part 1: points affected in ${size}x${size} area: ${tractorBeam.pointsAffected}`);
console.log('');

// PART 2
size = 100
const closestPos = tractorBeam.closestBoxPosition(size);
// TODO move this to Tractor.checksum() static method
const checksum = closestPos[1] * 10000 + closestPos[0];
console.log(`part 2: box location:     ${closestPos}`);
console.log('part 2: expected answer:  9760485');
console.log(`part 2: puzzle answer:    ${checksum}`);
console.log('');
