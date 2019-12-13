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
