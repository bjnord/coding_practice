'use strict';
const Tetris = require('../src/tetris');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const tetris = new Tetris(input);

// PART 1
tetris.dropShapes(2022);
console.log('part 1: expected answer:                3141');
console.log(`part 1: board height after 2022 shapes: ${tetris.boardHeight()}`);
console.log('');

// PART 2
const answer2 = 0;
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
