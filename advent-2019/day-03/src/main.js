var Wire = require('../src/wire');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
let programStr = input.trim().split(/\s+/);
let wire = new Wire(programStr[0]);
let wire2 = new Wire(programStr[1]);

// PART 1
let distance = wire.closestIntersectionWith(wire2);
console.log('part 1: expected answer is:               4981');
console.log(`part 1: distance to closest intersection: ${distance}`);
console.log('');
