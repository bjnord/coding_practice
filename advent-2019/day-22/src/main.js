'use strict';
const CardOfInterest = require('../src/card_of_interest');
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

// PART 2
const cardPos = 2020;
// 0b011011001000010001011010111101010110001100111111, 48 bits (top 0)
const deckSize = 119315717514047;  // prime
const cardOfInt = new CardOfInterest(deckSize, cardPos);
// 0b010111001000100010001110110110111100101011110101, 48 bits (top 0)
const shuffleTimes = 101741582076661;  // prime
cardOfInt.doTechniquesNTimes(input, shuffleTimes);
console.log('part 2: expected answer:           41685581334351');
console.log(`part 2: card at position ${cardPos} is:  ${cardOfInt.card}`);
console.log('');
