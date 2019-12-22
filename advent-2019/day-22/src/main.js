'use strict';
const Deck = require('../src/deck');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const deck = new Deck(10007);
deck.doTechniques(input);
const pos = deck.cards.indexOf(2019);
console.log('part 1: expected answer:            8502');
console.log(`part 1: position of card #2019 is:  ${pos}`);
console.log('');
