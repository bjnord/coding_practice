'use strict';
const expect = require('chai').expect;
const grove = require('../src/grove');
const exampleInput = '1\n2\n-3\n3\n-2\n0\n4\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(grove.parseLine('1')).to.eql(1);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      1,
      2,
      -3,
      3,
      -2,
      0,
      4,
    ];
    expect(grove.parse(exampleInput)).to.eql(expected);
  });
});
describe('decrypting tests', () => {
  it('should do left rotations properly', () => {
    // TODO should also check slotIndex[] before/after
    const tests = [
      { // rotate at left edge
        count:     7,
        slots:     [3, 4, 5, 6, 0, 1, 2],
        slotIndex: [],
        _fromSlot: 0,
        _toSlot:   1,
        _newSlots: [4, 3, 5, 6, 0, 1, 2],
      },
      { // rotate at right edge
        count:     7,
        slots:     [2, 4, 6, 0, 1, 3, 5],
        slotIndex: [],
        _fromSlot: 5,
        _toSlot:   6,
        _newSlots: [2, 4, 6, 0, 1, 5, 3],
      },
      { // rotate small in middle
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 2,
        _toSlot:   4,
        _newSlots: [1, 4, 5, 3, 2, 6, 0],
      },
      { // rotate big in middle
        count:     7,
        slots:     [5, 6, 0, 2, 1, 3, 4],
        slotIndex: [],
        _fromSlot: 1,
        _toSlot:   5,
        _newSlots: [5, 0, 2, 1, 3, 6, 4],
      },
      { // rotate all
        count:     7,
        slots:     [6, 5, 4, 3, 2, 1, 0],
        slotIndex: [],
        _fromSlot: 0,
        _toSlot:   6,
        _newSlots: [5, 4, 3, 2, 1, 0, 6],
      },
    ];
    for (const test of tests) {
      grove.rotateLeft(test, test._fromSlot, test._toSlot);
      expect(test.slots).to.eql(test._newSlots);
    }
  });
  it('should throw exceptions for invalid left rotations', () => {
    const badFromFn = () => { grove.rotateLeft({count: 5}, -1, 2); };
    expect(badFromFn).to.throw(SyntaxError);
    const badToFn = () => { grove.rotateLeft({count: 5}, 2, 5); };
    expect(badToFn).to.throw(SyntaxError);
    const badOrderFn = () => { grove.rotateLeft({count: 5}, 3, 2); };
    expect(badOrderFn).to.throw(SyntaxError);
  });
  it('should do right rotations properly', () => {
    // TODO should also check slotIndex[] before/after
    const tests = [
      { // rotate at left edge
        count:     7,
        slots:     [3, 4, 5, 6, 0, 1, 2],
        slotIndex: [],
        _fromSlot: 0,
        _toSlot:   1,
        _newSlots: [4, 3, 5, 6, 0, 1, 2],
      },
      { // rotate at right edge
        count:     7,
        slots:     [2, 4, 6, 0, 1, 3, 5],
        slotIndex: [],
        _fromSlot: 5,
        _toSlot:   6,
        _newSlots: [2, 4, 6, 0, 1, 5, 3],
      },
      { // rotate small in middle
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 2,
        _toSlot:   4,
        _newSlots: [1, 4, 3, 2, 5, 6, 0],
      },
      { // rotate big in middle
        count:     7,
        slots:     [5, 6, 0, 2, 1, 3, 4],
        slotIndex: [],
        _fromSlot: 1,
        _toSlot:   5,
        _newSlots: [5, 3, 6, 0, 2, 1, 4],
      },
      { // rotate all
        count:     7,
        slots:     [6, 5, 4, 3, 2, 1, 0],
        slotIndex: [],
        _fromSlot: 0,
        _toSlot:   6,
        _newSlots: [0, 6, 5, 4, 3, 2, 1],
      },
    ];
    for (const test of tests) {
      grove.rotateRight(test, test._fromSlot, test._toSlot);
      expect(test.slots).to.eql(test._newSlots);
    }
  });
  it('should throw exceptions for invalid right rotations', () => {
    const badFromFn = () => { grove.rotateRight({count: 5}, -1, 2); };
    expect(badFromFn).to.throw(SyntaxError);
    const badToFn = () => { grove.rotateRight({count: 5}, 2, 5); };
    expect(badToFn).to.throw(SyntaxError);
    const badOrderFn = () => { grove.rotateRight({count: 5}, 3, 2); };
    expect(badOrderFn).to.throw(SyntaxError);
  });
  it('should calculate destSlot correctly', () => {
    // these are the ones shown in the puzzle example:
    expect(grove.destSlot(1, 0, 7)).to.equal(1);
    expect(grove.destSlot(2, 0, 7)).to.equal(2);
    expect(grove.destSlot(-3, 1, 7)).to.equal(4);
    expect(grove.destSlot(3, 2, 7)).to.equal(5);
    expect(grove.destSlot(-2, 2, 7)).to.equal(6);
    expect(grove.destSlot(0, 3, 7)).to.equal(3);
    expect(grove.destSlot(4, 5, 7)).to.equal(3);
  });
  it('should execute each move correctly (puzzle example)', () => {
    const numbers = grove.parse(exampleInput);
    const state = grove.state(numbers);
    const expected = [
      // Initial arrangement:
      [1, 2, -3, 3, -2, 0, 4],
      // 1 moves between 2 and -3:
      [2, 1, -3, 3, -2, 0, 4],
      // 2 moves between -3 and 3:
      [1, -3, 2, 3, -2, 0, 4],
      // -3 moves between -2 and 0:
      [1, 2, 3, -2, -3, 0, 4],
      // 3 moves between 0 and 4:
      [1, 2, -2, -3, 0, 3, 4],
      // -2 moves between 4 and 1:
      [1, 2, -3, 0, 3, 4, -2],
      // 0 does not move:
      [1, 2, -3, 0, 3, 4, -2],
      // 4 moves between -3 and 0:
      [1, 2, -3, 4, 0, 3, -2],
    ];
    const exp0 = expected.shift();
    expect(grove.currentNumbers(state)).to.eql(exp0);
    for (const exp of expected) {
      grove.doMove(state);
      expect(grove.currentNumbers(state)).to.eql(exp);
    }
  });
  it('should find grove coordinates correctly (puzzle example)', () => {
    const numbers = grove.parse(exampleInput);
    const state = grove.state(numbers);
    grove.doMoves(state);
    expect(grove.coordinates(state)).to.eql([4, -3, 2]);
  });
});
