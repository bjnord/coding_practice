'use strict';
const CardOfInterest = require('../src/card_of_interest');
const Deck = require('../src/deck');

const deckSize = 40037;  // prime
const cardPos = 2020;
const nRounds = 211;  // prime

/*
 * WITH DECK
 */
console.debug('EXPECTED: card at 2020 = 3540');
const deck = new Deck(deckSize);
const techniques = 'deal into new stack\ncut -201\ndeal with increment 71\ncut 81\ncut -41\ndeal with increment 79\ncut 305\ndeal with increment 91\ndeal with increment 333\ncut -117\ndeal into new stack\ncut -301\ndeal with increment 81\ncut 91\ncut -141\ndeal with increment 89\ncut 315\ndeal with increment 101\ndeal with increment 343\ncut -127\n';
deck.doTechniquesNTimes(techniques, nRounds);
console.debug(`  W/DECK: card at ${cardPos} = ${deck.cardAt(cardPos)}`);

/*
 * WITH CARD
 */
const cardOfInt = new CardOfInterest(deckSize, cardPos);
cardOfInt.doTechniquesNTimes(techniques, nRounds);
console.debug(`  W/CARD: card at ${cardPos} = ${cardOfInt.card}`);
