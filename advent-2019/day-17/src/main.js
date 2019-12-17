'use strict';
const Scaffold = require('../src/scaffold');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const scaffold = new Scaffold(input);
scaffold.run();
scaffold.findIntersections();
console.log('part 1: expected answer:                          5788');
const alignmentSum = scaffold.intersections()
  .map((pos) => pos[0] * pos[1])
  .reduce((sum, a) => sum + a, 0);
console.log(`part 1: sum of intersection alignment parameters: ${alignmentSum}`);
console.log('');
