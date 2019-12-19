'use strict';
const TractorBeam = require('../src/tractor_beam');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const tractorBeam = new TractorBeam(input);
const size = 50;
tractorBeam.run(size);
console.log('part 1: expected answer:               ?');
console.log(`part 1: points affected in ${size}x${size} area: ${tractorBeam.squaresAffected}`);
console.log('');
