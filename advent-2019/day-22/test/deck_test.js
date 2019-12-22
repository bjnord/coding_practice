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
