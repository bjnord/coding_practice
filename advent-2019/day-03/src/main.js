'use strict';
const Wire = require('../src/wire');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const programStr = input.trim().split(/\s+/);
const wire = new Wire(programStr[0]);
const wire2 = new Wire(programStr[1]);

// PART 1
const distance = wire.closestIntersectionWith(wire2);
console.log('part 1: expected answer is:               4981');
console.log(`part 1: distance to closest intersection: ${distance}`);
console.log('');

// PART 2
const steps = wire.shortestIntersectionWith(wire2);
console.log('part 1: expected answer is:              164012');
console.log(`part 1: fewest steps to an intersection: ${steps}`);
