'use strict';
const ArcadeGame = require('../src/arcade_game');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const arcadeGame = new ArcadeGame(input);
arcadeGame.run();
console.log('part 1: expected answer:      315');
console.log(`part 1: count of block tiles: ${arcadeGame.countOf(2)}`);
console.log('');

// PART 2
const playGame = new ArcadeGame(input);
playGame.insertQuarters();
playGame.run();
console.log('part 2: expected answer:      0');
console.log(`part 2: count of block tiles: ${playGame.countOf(2)}`);
console.log('part 2: expected answer:      16171');
console.log(`part 2: final game score:     ${playGame.score}`);
console.log('');
