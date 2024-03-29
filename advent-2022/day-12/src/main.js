'use strict';
const hill = require('../src/hill');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const heightMap = hill.parse(input);

// PART 1
const steps = hill.dijkstra(heightMap);
console.log('part 1: expected answer:                481');
console.log(`part 1: fewest steps to best signal:    ${steps}`);
console.log('');

// PART 2
const fewestSteps = hill.fewestSteps(heightMap);
console.log('part 2: expected answer:                480');
console.log(`part 2: actual answer:                  ${fewestSteps}`);
console.log('');
