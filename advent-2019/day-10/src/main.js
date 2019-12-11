'use strict';
const AsteroidMap = require('../src/asteroid_map');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const am = new AsteroidMap(input);

// PART 1
const loc = am.bestLocation();
console.log('part 1: expected answer:                      278');
console.log(`part 1: asteroids visible from best location: ${loc.count}`);
console.log('');
