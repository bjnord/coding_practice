'use strict';
const Scaffold = require('../src/scaffold');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
let scaffold = new Scaffold(input);
scaffold.run();
scaffold.findIntersections();
console.log('part 1: expected answer:                          5788');
const alignmentSum = scaffold.intersections()
  .map((pos) => pos[0] * pos[1])
  .reduce((sum, a) => sum + a, 0);
console.log(`part 1: sum of intersection alignment parameters: ${alignmentSum}`);
console.log('');

// PART 2
scaffold = new Scaffold(input);
scaffold.run(2);
console.log('part 2: expected answer:                648545');
console.log(`part 2: dust collected by varuum robot: ${scaffold.dust}`);
