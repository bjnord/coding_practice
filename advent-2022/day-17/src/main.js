'use strict';
const Tetris = require('../src/tetris');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
let tetris = new Tetris(input);
tetris.dropShapes(2022);
console.log('part 1: expected answer:                3141');
console.log(`part 1: board height after 2022 shapes: ${tetris.boardHeight()}`);
console.log('');

// PART 2
tetris = new Tetris(input);
const nShapes = 1000000000000n;
const answer2 = tetris.dropShapesCyclical(nShapes);
console.log('part 2: expected answer:                1');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
