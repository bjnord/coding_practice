'use strict';
const Tetris = require('../src/tetris');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

if (process.argv[process.argv.length - 1] === '--dump') {
  const exampleInput = fs.readFileSync('input/example.txt', 'utf8');
  const example = new Tetris(exampleInput, true);
  example.dropShapes(11);
  process.exit(0);
}

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
console.log('part 2: expected answer:                1561739130391');
console.log(`part 2: board height after 1T shapes:   ${answer2}`);
console.log('');
