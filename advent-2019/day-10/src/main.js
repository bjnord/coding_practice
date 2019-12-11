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

// PART 2
const origin = loc.pos;
let vaporized = [];
while (am.asteroidsVisibleFrom(origin).length) {
  vaporized = vaporized.concat(am.vaporizeFrom(origin));
}
console.log('part 2: expected answer:                      1417');
console.log(`part 2: location of 200th vaporized asteroid: [${vaporized[199]}]`);
console.log(`part 2: X * 100 + Y:                          ${vaporized[199][1] * 100 + vaporized[199][0]}`);
