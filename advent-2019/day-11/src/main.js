'use strict';
const Robot = require('../src/robot');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const blackRobot = new Robot(input);
blackRobot.run();
console.log('part 1: expected answer:              1985');
console.log(`part 1: panels painted at least once: ${blackRobot.panelPaintedCount}`);
console.log('');

// PART 2
const whiteRobot = new Robot(input, 1);
whiteRobot.run();
console.log('part 2: expected answer:              BLCZCJLZ');
whiteRobot.dump();
