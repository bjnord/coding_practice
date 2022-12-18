'use strict';
const lava = require('../src/lava');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const droplet = lava.parse(input);

// PART 1
const answer1 = lava.surfaceArea(droplet);
console.log('part 1: expected answer:                  3448');
console.log(`part 1: simple surface area of droplet:   ${answer1}`);
console.log('');

// PART 2
const answer2 = lava.trueSurfaceArea(droplet);
console.log('part 2: expected answer:                  **TOOLOW** 2040 **TOOHIGH** 2152');
console.log(`part 2: exterior surface area of droplet: ${answer2}`);
console.log('');
