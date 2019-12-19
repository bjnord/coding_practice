'use strict';
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const fs = require('fs');

const exampleGrid = (n) => {
  const input = fs.readFileSync(`input/example_grid_${n}.txt`, 'utf8');
  const lines = input.trim().split(/\n/);
  const key = {
    0: {name: 'empty', render: '.'},
    1: {name: 'pulled', render: '#'},
    2: {name: 'ship', render: 'O'},
  };
  const handleUnknown = (pos, ch) => {
    throw new Error(`unknown character ${ch} at ${pos}`);
  };
  return PuzzleGrid.from(lines, key, [0, 0], handleUnknown);
};
const dimensions = (grid) => {
  // TODO cheating by peeking at private member
  //      move to PuzzleGrid.dimensions() method
  const squares = Array.from(grid._grid.keys()).map((k) => k.split(/,/).map((str) => Number(str)));
  const squareMin = squares.reduce((mins, p) => [Math.min(p[0], mins[0]), Math.min(p[1], mins[1])], [999999, 999999]);
  const squareMax = squares.reduce((maxes, p) => [Math.max(p[0], maxes[0]), Math.max(p[1], maxes[1])], [-999999, -999999]);
  const height = squareMax[0] - squareMin[0] + 1;
  const width = squareMax[1] - squareMin[1] + 1;
  return [height, width];
};
const dumpProgram = (n, grid) => {
  const dim = dimensions(grid);
  console.log(`Intcode for example ${n} (${dim[0]} x ${dim[1]}):`);
  const program = `3,20,3,21,2,21,22,24,1,24,20,24,9,24,204,25,99,0,0,0,0,0,${dim[1]},${dim[0]},0`.split(',').map((n) => Number(n));
  for (let y = 0; y < dim[0]; y++) {
    for (let x = 0; x < dim[1]; x++) {
      const i = y * dim[1] + x + 25;
      program[i] = grid.get([y, x]) ? 1 : 0;
    }
  }
  console.log(program.join(','));
};

const example1 = exampleGrid(1);
dumpProgram(1, example1);
console.log('');
const example2 = exampleGrid(2);
dumpProgram(2, example2);
console.log('');
