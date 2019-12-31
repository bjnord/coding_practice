'use strict';
const expect = require('chai').expect;
const Deck = require('../src/deck');
describe('constructor tests', () => {
  it ('should construct a new deck of cards correctly [puzzle example]', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    const deck = new Deck(10);
    expect(deck.cards).to.eql(expected);
  });
  it ('should throw an exception if N < 2', () => {
    const call = () => { new Deck(1); };
    expect(call).to.throw(Error, 'invalid number of cards');
  });
});
describe('card position tests', () => {
  let positionDeck;
  before(() => {
    positionDeck = new Deck(11);
  });
  it ('should retrieve a card at the given position correctly', () => {
    expect(positionDeck.cardAt(0)).to.eql(0);
    expect(positionDeck.cardAt(3)).to.eql(3);
    expect(positionDeck.cardAt(10)).to.eql(10);
  });
  // we don't check that position is in range, for speed
});
describe('"deal into new stack" tests', () => {
  it('it should "deal into new stack" correctly [puzzle example]', () => {
    const expected = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    const deck = new Deck(10);
    deck.dealIntoNewStack();
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal into new stack" correctly, as technique [puzzle example]', () => {
    const expected = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0];
    const deck = new Deck(10);
    deck.doTechnique('deal into new stack');
    expect(deck.cards).to.eql(expected);
  });
});
describe('"cut N cards" tests', () => {
  let deck;
  beforeEach(() => {
    deck = new Deck(10);
  });
  it('it should "cut N cards" correctly for N > 0 [puzzle example]', () => {
    const expected = [3, 4, 5, 6, 7, 8, 9, 0, 1, 2];
    deck.cutCards(3);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "cut N cards" correctly for N > 0, as technique [puzzle example]', () => {
    const expected = [3, 4, 5, 6, 7, 8, 9, 0, 1, 2];
    deck.doTechnique('cut 3');
    expect(deck.cards).to.eql(expected);
  });
  it('it should "cut N cards" correctly for N < 0 [puzzle example]', () => {
    const expected = [6, 7, 8, 9, 0, 1, 2, 3, 4, 5];
    deck.cutCards(-4);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "cut N cards" correctly for N < 0, as technique [puzzle example]', () => {
    const expected = [6, 7, 8, 9, 0, 1, 2, 3, 4, 5];
    deck.doTechnique('cut -4');
    expect(deck.cards).to.eql(expected);
  });
  it('it should "cut N cards" correctly for N = 0', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    deck.cutCards(0);
    expect(deck.cards).to.eql(expected);
  });
  it('it should wrap position correctly for N > 0 [3 then 7]', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    deck.cutCards(3);
    deck.cutCards(7);
    expect(deck.cards).to.eql(expected);
  });
  it('it should wrap position correctly for N > 0 [9 then 2]', () => {
    const expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
    deck.cutCards(9);
    deck.cutCards(2);
    expect(deck.cards).to.eql(expected);
  });
  it('it should wrap position correctly for N < 0 [-4 then -6]', () => {
    const expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    deck.cutCards(-4);
    deck.cutCards(-6);
    expect(deck.cards).to.eql(expected);
  });
  it('it should wrap position correctly for N < 0 [-9 then -2]', () => {
    const expected = [9, 0, 1, 2, 3, 4, 5, 6, 7, 8];
    deck.cutCards(-9);
    deck.cutCards(-2);
    expect(deck.cards).to.eql(expected);
  });
});
describe('combined "cut N cards"/"deal into new stack" technique tests', () => {
  let deck;
  beforeEach(() => {
    deck = new Deck(10);
  });
  it('it should "cut N cards" then "deal into new stack" correctly for N > 0', () => {
    const expected = [4, 3, 2, 1, 0, 9, 8, 7, 6, 5];
    deck.cutCards(5);
    deck.dealIntoNewStack();
    expect(deck.cards).to.eql(expected);
  });
  it('it should "cut N cards" then "deal into new stack" correctly for N < 0', () => {
    const expected = [7, 6, 5, 4, 3, 2, 1, 0, 9, 8];
    deck.cutCards(-2);
    deck.dealIntoNewStack();
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal into new stack" then "cut N cards" correctly for N > 0', () => {
    const expected = [8, 7, 6, 5, 4, 3, 2, 1, 0, 9];
    deck.dealIntoNewStack();
    deck.cutCards(1);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal into new stack" then "cut N cards" correctly for N < 0', () => {
    const expected = [5, 4, 3, 2, 1, 0, 9, 8, 7, 6];
    deck.dealIntoNewStack();
    deck.cutCards(-6);
    expect(deck.cards).to.eql(expected);
  });
});
describe('"deal with increment N" tests', () => {
  it('it should "deal with increment N" correctly [puzzle example]', () => {
    const expected = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3];
    const deck = new Deck(10);
    deck.dealWithIncrement(3);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal with increment N" correctly, as technique [puzzle example]', () => {
    const expected = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3];
    const deck = new Deck(10);
    deck.doTechnique('deal with increment 3');
    expect(deck.cards).to.eql(expected);
  });
  it('"deal with increment N" should always return same number of cards', () => {
    [...Array(9).keys()].map((n) => n+1).forEach((n) => {
      const deck = new Deck(10);
      deck.dealWithIncrement(n);
      expect(deck.cards.length).to.eql(10);
    });
  });
  it ('should throw an exception if N < 1', () => {
    const deck = new Deck(10);
    const call = () => { deck.dealWithIncrement(0); };
    expect(call).to.throw(Error, 'invalid increment');
  });
});
describe('combined "cut N cards"/"deal with increment N" technique tests', () => {
  let deck;
  beforeEach(() => {
    deck = new Deck(10);
  });
  it('it should "cut N cards" then "deal with increment N" correctly for N > 0', () => {
    const expected = [4, 7, 0, 3, 6, 9, 2, 5, 8, 1];
    deck.cutCards(4);
    deck.dealWithIncrement(7);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "cut N cards" then "deal with increment N" correctly for N < 0', () => {
    const expected = [8, 5, 2, 9, 6, 3, 0, 7, 4, 1];
    deck.cutCards(-2);
    deck.dealWithIncrement(3);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal with increment N" then "cut N cards" correctly for N > 0', () => {
    const expected = [5, 8, 1, 4, 7, 0, 3, 6, 9, 2];
    deck.dealWithIncrement(7);
    deck.cutCards(5);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal with increment N" then "cut N cards" correctly for N < 0', () => {
    const expected = [9, 6, 3, 0, 7, 4, 1, 8, 5, 2];
    deck.dealWithIncrement(3);
    deck.cutCards(-3);
    expect(deck.cards).to.eql(expected);
  });
});
describe('combined all-technique tests', () => {
  let deck;
  beforeEach(() => {
    deck = new Deck(10);
  });
  it('it should "cut N cards", "deal with increment N", "deal into new stack" correctly', () => {
    const expected = [5, 8, 1, 4, 7, 0, 3, 6, 9, 2];
    deck.cutCards(2);
    deck.dealWithIncrement(3);
    deck.dealIntoNewStack();
    expect(deck.cards).to.eql(expected);
  });
  it('it should "cut N cards", "deal into new stack", "deal with increment N" correctly', () => {
    const expected = [4, 1, 8, 5, 2, 9, 6, 3, 0, 7];
    deck.cutCards(-5);
    deck.dealIntoNewStack();
    deck.dealWithIncrement(7);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal into new stack", "cut N cards", "deal with increment N" correctly', () => {
    const expected = [5, 2, 9, 6, 3, 0, 7, 4, 1, 8];
    deck.dealIntoNewStack();
    deck.cutCards(4);
    deck.dealWithIncrement(7);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal into new stack", "deal with increment N", "cut N cards" correctly', () => {
    const expected = [7, 0, 3, 6, 9, 2, 5, 8, 1, 4];
    deck.dealIntoNewStack();
    deck.dealWithIncrement(3);
    deck.cutCards(-4);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal with increment N", "deal into new stack", "cut N cards" correctly', () => {
    const expected = [4, 7, 0, 3, 6, 9, 2, 5, 8, 1];
    deck.dealWithIncrement(3);
    deck.dealIntoNewStack();
    deck.cutCards(7);
    expect(deck.cards).to.eql(expected);
  });
  it('it should "deal with increment N", "cut N cards", "deal into new stack" correctly', () => {
    const expected = [0, 7, 4, 1, 8, 5, 2, 9, 6, 3];
    deck.dealWithIncrement(7);
    deck.cutCards(-9);
    deck.dealIntoNewStack();
    expect(deck.cards).to.eql(expected);
  });
});
describe('technique tests', () => {
  it('it should use puzzle example technique #1 correctly', () => {
    const result = '0 3 6 9 2 5 8 1 4 7'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal with increment 7\ndeal into new stack\ndeal into new stack\n';
    const deck = new Deck(10);
    deck.doTechniques(techniques);
    expect(deck.cards).to.eql(result);
  });
  it('it should use puzzle example technique #2 correctly', () => {
    const result = '3 0 7 4 1 8 5 2 9 6'.split(/\s+/).map((n) => Number(n));
    const techniques = 'cut 6\ndeal with increment 7\ndeal into new stack\n';
    const deck = new Deck(10);
    deck.doTechniques(techniques);
    expect(deck.cards).to.eql(result);
  });
  it('it should use puzzle example technique #3 correctly', () => {
    const result = '6 3 0 7 4 1 8 5 2 9'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal with increment 7\ndeal with increment 9\ncut -2\n';
    const deck = new Deck(10);
    deck.doTechniques(techniques);
    expect(deck.cards).to.eql(result);
  });
  it('it should use puzzle example technique #4 correctly', () => {
    const result = '9 2 5 8 1 4 7 0 3 6'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal into new stack\ncut -2\ndeal with increment 7\ncut 8\ncut -4\ndeal with increment 7\ncut 3\ndeal with increment 9\ndeal with increment 3\ncut -1\n';
    const deck = new Deck(10);
    deck.doTechniques(techniques);
    expect(deck.cards).to.eql(result);
  });
  it ('should throw an exception for an unknown technique', () => {
    const deck = new Deck(10);
    const call = () => { deck.doTechniques('well, shake it up, baby, now\ntwist and shout\n'); };
    expect(call).to.throw(Error, 'unknown technique "well, shake it up, baby, now"');
  });
});
describe('repeated technique tests', () => {
  it('it should use puzzle example technique #2 THRICE correctly', () => {
    const result = '1 4 7 0 3 6 9 2 5 8'.split(/\s+/).map((n) => Number(n));
    const techniques = 'cut 6\ndeal with increment 7\ndeal into new stack\n';
    const deck = new Deck(10);
    deck.doTechniquesNTimes(techniques, 3);
    expect(deck.cards).to.eql(result);
  });
  it('it should use puzzle example technique #3 TWICE correctly', () => {
    const result = '8 7 6 5 4 3 2 1 0 9'.split(/\s+/).map((n) => Number(n));
    const techniques = 'deal with increment 7\ndeal with increment 9\ncut -2\n';
    const deck = new Deck(10);
    deck.doTechniquesNTimes(techniques, 2);
    expect(deck.cards).to.eql(result);
  });
});
