'use strict';
const refinery = require('../src/refinery');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const inv = refinery.parse(input);
const oreRequired = refinery.calculate(inv, {units: 1, chem: 'FUEL'});
console.log('part 1: expected answer:                783895');
console.log(`part 1: ORE required to produce 1 FUEL: ${oreRequired}`);
console.log('');
