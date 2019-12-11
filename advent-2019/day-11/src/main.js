'use strict';
const Robot = require('../src/robot');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const robot = new Robot(input);

// PART 1
robot.run();
console.log('part 1: expected answer:              1985');
console.log(`part 1: panels painted at least once: ${robot.panelPaintedCount}`);
console.log('');
