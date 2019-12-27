'use strict';
const Starship = require('../src/starship');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const starship = new Starship(input);
const password = starship.search();
console.log('part 1: expected answer:  1090529280');
console.log(`part 1: airlock password: ${password}`);
console.log('');
