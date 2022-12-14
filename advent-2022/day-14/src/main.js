'use strict';
const regolith = require('../src/regolith');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
let map = regolith.makeMap(regolith.parse(input));
const answer1 = regolith.totalSand(map);
console.log('part 1: expected answer (no floor):      644');
console.log(`part 1: units of sand that come to rest: ${answer1}`);
console.log('');

// PART 2
map = regolith.makeMap(regolith.parse(input));
map.floorY = map.maxY + 2;
const answer2 = regolith.totalSand(map);
console.log('part 2: expected answer (floor):         27324');
console.log(`part 2: units of sand that come to rest: ${answer2}`);
console.log('');
