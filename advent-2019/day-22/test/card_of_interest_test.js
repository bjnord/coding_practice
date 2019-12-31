'use strict';
const expect = require('chai').expect;
const CardOfInterest = require('../src/card_of_interest');
const deckSize = 10;
const cardPos = 3;  // could be any one of the 10
describe('constructor tests', () => {
  it ('should construct a new card-of-interest correctly [puzzle example]', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it ('should throw an exception if deckSize < 2', () => {
    const call = () => { new CardOfInterest(1, 0); };
    expect(call).to.throw(Error, 'invalid number of cards');
  });
  it ('should throw an exception if cardPosition < 0', () => {
    const call = () => { new CardOfInterest(8, -1); };
    expect(call).to.throw(Error, 'invalid card position');
  });
  it ('should throw an exception if cardPosition >= deckSize', () => {
    const call = () => { new CardOfInterest(9, 9); };
    expect(call).to.throw(Error, 'invalid card position for a 9-card deck');
  });
});
describe('card position tests', () => {
  it ('should retrieve a card at the given position correctly', () => {
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    expect(cardOfInt.card).to.eql(cardPos);
  });
  // we don't check that position is in range, for speed
});
describe('"deal into new stack" tests', () => {
  it('it should "deal into new stack" correctly [puzzle example]', () => {
    const expected = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.dealIntoNewStack();
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal into new stack" correctly, as technique [puzzle example]', () => {
    const expected = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechnique('deal into new stack');
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
});
describe('"cut N cards" tests', () => {
  let cardOfInt;
  beforeEach(() => {
    cardOfInt = new CardOfInterest(deckSize, cardPos);
  });
  it('it should "cut N cards" correctly for N > 0 [puzzle example]', () => {
    const expected = [3, 4, 5, 6, 7, 8, 9, 0, 1, 2];
    cardOfInt.cutCards(3);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "cut N cards" correctly for N > 0, as technique [puzzle example]', () => {
    const expected = [3, 4, 5, 6, 7, 8, 9, 0, 1, 2];
    cardOfInt.doTechnique('cut 3');
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "cut N cards" correctly for N < 0 [puzzle example]', () => {
    const expected = [6, 7, 8, 9, 0, 1, 2, 3, 4, 5];
    cardOfInt.cutCards(-4);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "cut N cards" correctly for N < 0, as technique [puzzle example]', () => {
    const expected = [6, 7, 8, 9, 0, 1, 2, 3, 4, 5];
    cardOfInt.doTechnique('cut -4');
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "cut N cards" correctly for N = 0', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    cardOfInt.cutCards(0);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should wrap position correctly for N > 0 [3 then 7]', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    cardOfInt.cutCards(3);
    cardOfInt.cutCards(7);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should wrap position correctly for N > 0 [9 then 2]', () => {
    const expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
    cardOfInt.cutCards(9);
    cardOfInt.cutCards(2);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should wrap position correctly for N < 0 [-4 then -6]', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    cardOfInt.cutCards(-4);
    cardOfInt.cutCards(-6);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should wrap position correctly for N < 0 [-9 then -2]', () => {
    const expected = [9, 0, 1, 2, 3, 4, 5, 6, 7, 8];
    cardOfInt.cutCards(-9);
    cardOfInt.cutCards(-2);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
});
describe('combined "cut N cards"/"deal into new stack" technique tests', () => {
  let cardOfInt;
  beforeEach(() => {
    cardOfInt = new CardOfInterest(deckSize, cardPos);
  });
  it('it should "cut N cards" then "deal into new stack" correctly for N > 0', () => {
    const expected = [4, 3, 2, 1, 0, 9, 8, 7, 6, 5];
    cardOfInt.cutCards(5);
    cardOfInt.dealIntoNewStack();
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "cut N cards" then "deal into new stack" correctly for N < 0', () => {
    const expected = [7, 6, 5, 4, 3, 2, 1, 0, 9, 8];
    cardOfInt.cutCards(-2);
    cardOfInt.dealIntoNewStack();
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal into new stack" then "cut N cards" correctly for N > 0', () => {
    const expected = [8, 7, 6, 5, 4, 3, 2, 1, 0, 9];
    cardOfInt.dealIntoNewStack();
    cardOfInt.cutCards(1);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal into new stack" then "cut N cards" correctly for N < 0', () => {
    const expected = [5, 4, 3, 2, 1, 0, 9, 8, 7, 6];
    cardOfInt.dealIntoNewStack();
    cardOfInt.cutCards(-6);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
});
describe('"deal with increment N" tests', () => {
  it('it should "deal with increment N" correctly [puzzle example]', () => {
    const expected = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3];
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.dealWithIncrement(3);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal with increment N" correctly, as technique [puzzle example]', () => {
    const expected = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3];
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechnique('deal with increment 3');
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it ('should throw an exception if N < 1', () => {
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    const call = () => { cardOfInt.dealWithIncrement(0); };
    expect(call).to.throw(Error, 'invalid increment');
  });
});
describe('combined "cut N cards"/"deal with increment N" technique tests', () => {
  let cardOfInt;
  beforeEach(() => {
    cardOfInt = new CardOfInterest(deckSize, cardPos);
  });
  it('it should "cut N cards" then "deal with increment N" correctly for N > 0', () => {
    const expected = [4, 7, 0, 3, 6, 9, 2, 5, 8, 1];
    cardOfInt.cutCards(4);
    cardOfInt.dealWithIncrement(7);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "cut N cards" then "deal with increment N" correctly for N < 0', () => {
    const expected = [8, 5, 2, 9, 6, 3, 0, 7, 4, 1];
    cardOfInt.cutCards(-2);
    cardOfInt.dealWithIncrement(3);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal with increment N" then "cut N cards" correctly for N > 0', () => {
    const expected = [5, 8, 1, 4, 7, 0, 3, 6, 9, 2];
    cardOfInt.dealWithIncrement(7);
    cardOfInt.cutCards(5);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal with increment N" then "cut N cards" correctly for N < 0', () => {
    const expected = [9, 6, 3, 0, 7, 4, 1, 8, 5, 2];
    cardOfInt.dealWithIncrement(3);
    cardOfInt.cutCards(-3);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
});
describe('combined all-technique tests', () => {
  let cardOfInt;
  beforeEach(() => {
    cardOfInt = new CardOfInterest(deckSize, cardPos);
  });
  it('it should "cut N cards", "deal with increment N", "deal into new stack" correctly', () => {
    const expected = [5, 8, 1, 4, 7, 0, 3, 6, 9, 2];
    cardOfInt.cutCards(2);
    cardOfInt.dealWithIncrement(3);
    cardOfInt.dealIntoNewStack();
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "cut N cards", "deal into new stack", "deal with increment N" correctly', () => {
    const expected = [4, 1, 8, 5, 2, 9, 6, 3, 0, 7];
    cardOfInt.cutCards(-5);
    cardOfInt.dealIntoNewStack();
    cardOfInt.dealWithIncrement(7);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal into new stack", "cut N cards", "deal with increment N" correctly', () => {
    const expected = [5, 2, 9, 6, 3, 0, 7, 4, 1, 8];
    cardOfInt.dealIntoNewStack();
    cardOfInt.cutCards(4);
    cardOfInt.dealWithIncrement(7);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal into new stack", "deal with increment N", "cut N cards" correctly', () => {
    const expected = [7, 0, 3, 6, 9, 2, 5, 8, 1, 4];
    cardOfInt.dealIntoNewStack();
    cardOfInt.dealWithIncrement(3);
    cardOfInt.cutCards(-4);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal with increment N", "deal into new stack", "cut N cards" correctly', () => {
    const expected = [4, 7, 0, 3, 6, 9, 2, 5, 8, 1];
    cardOfInt.dealWithIncrement(3);
    cardOfInt.dealIntoNewStack();
    cardOfInt.cutCards(7);
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
  it('it should "deal with increment N", "cut N cards", "deal into new stack" correctly', () => {
    const expected = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3];
    cardOfInt.dealWithIncrement(7);
    cardOfInt.cutCards(-9);
    cardOfInt.dealIntoNewStack();
    expect(cardOfInt.card).to.eql(expected[cardPos]);
  });
});
describe('technique tests', () => {
  it('it should use puzzle example technique #1 correctly', () => {
    const result = '0 3 6 9 2 5 8 1 4 7'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal with increment 7\ndeal into new stack\ndeal into new stack\n';
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechniques(techniques);
    expect(cardOfInt.card).to.eql(result[cardPos]);
  });
  it('it should use puzzle example technique #2 correctly', () => {
    const result = '3 0 7 4 1 8 5 2 9 6'.split(/\s+/).map((n) => Number(n));
    const techniques = 'cut 6\ndeal with increment 7\ndeal into new stack\n';
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechniques(techniques);
    expect(cardOfInt.card).to.eql(result[cardPos]);
  });
  it('it should use puzzle example technique #3 correctly', () => {
    const result = '6 3 0 7 4 1 8 5 2 9'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal with increment 7\ndeal with increment 9\ncut -2\n';
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechniques(techniques);
    expect(cardOfInt.card).to.eql(result[cardPos]);
  });
  it('it should use puzzle example technique #4 correctly', () => {
    const result = '9 2 5 8 1 4 7 0 3 6'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal into new stack\ncut -2\ndeal with increment 7\ncut 8\ncut -4\ndeal with increment 7\ncut 3\ndeal with increment 9\ndeal with increment 3\ncut -1\n';
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechniques(techniques);
    expect(cardOfInt.card).to.eql(result[cardPos]);
  });
  it ('should throw an exception for an unknown technique', () => {
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    const call = () => { cardOfInt.doTechniques('well, shake it up, baby, now\ntwist and shout\n'); };
    expect(call).to.throw(Error, 'unknown technique "well, shake it up, baby, now"');
  });
});
describe('repeated technique tests', () => {
  it('it should use puzzle example technique #2 THRICE correctly', () => {
    const result = '1 4 7 0 3 6 9 2 5 8'.split(/\s+/).map((n) => Number(n));
    const techniques = 'cut 6\ndeal with increment 7\ndeal into new stack\n';
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechniquesNTimes(techniques, 3);
    expect(cardOfInt.card).to.eql(result[cardPos]);
  });
  it('it should use puzzle example technique #3 TWICE correctly', () => {
    const result = '8 7 6 5 4 3 2 1 0 9'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal with increment 7\ndeal with increment 9\ncut -2\n';
    const cardOfInt = new CardOfInterest(deckSize, cardPos);
    cardOfInt.doTechniquesNTimes(techniques, 2);
    expect(cardOfInt.card).to.eql(result[cardPos]);
  });
});
