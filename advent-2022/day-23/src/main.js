'use strict';
const plant = require('../src/plant');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const elves = plant.parse(input);

// PART 1
const state = plant.initialState(elves);
plant.doRounds(state, 10);
console.log('part 1: expected answer:              3780');
console.log(`part 1: empty tiles in bounding rect: ${plant.empties(state)}`);
console.log('');

// PART 2
plant.doRounds(state);
const answer2 = state.round - 1;
console.log('part 2: expected answer:              930');
console.log(`part 2: stopping round:               ${answer2}`);
console.log('');
