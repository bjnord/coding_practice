'use strict';
const chai = require('chai');
const expect = chai.expect;
const Assertion = chai.Assertion;
const grove = require('../src/grove');
const exampleInput = '1\n2\n-3\n3\n-2\n0\n4\n';
const assertRotatedEq = ((state, expectedNumbers) => {
  const currentNumbers = grove.currentNumbers(state);
  const checkRotatedEq = new Assertion(currentNumbers);
  checkRotatedEq.assert(
    grove.rotatedEqual(currentNumbers, expectedNumbers),
    'expected #{this}',
    'expected #{this} not',
    expectedNumbers,
    currentNumbers,
    true
  );
});
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
describe('array equality tests', () => {
  it('should detect equal unrotated arrays', () => {
    expect(grove.rotatedEqual([1, 4, 9, 25], [1, 4, 9, 25])).to.be.true;
  });
  it('should detect equal rotated arrays', () => {
    expect(grove.rotatedEqual([1, 4, 9, 25], [4, 9, 25, 1])).to.be.true;
    expect(grove.rotatedEqual([1, 4, 9, 25], [9, 25, 1, 4])).to.be.true;
    expect(grove.rotatedEqual([1, 4, 9, 25], [25, 1, 4, 9])).to.be.true;
  });
  it('should detect unequal swapped arrays', () => {
    expect(grove.rotatedEqual([1, 4, 9, 25], [4, 1, 9, 25])).to.be.false;
    expect(grove.rotatedEqual([1, 4, 9, 25], [1, 9, 25, 4])).to.be.false;
  });
  it('should detect unequal different arrays', () => {
    expect(grove.rotatedEqual([1, 4, 9, 25], [1, 4, 8, 25])).to.be.false;
    expect(grove.rotatedEqual([1, 4, 9, 25], [9, 24, 1, 4])).to.be.false;
  });
  it('should throw exception for different-sized arrays', () => {
    const badEqualFn = () => { grove.rotatedEqual([1, 4, 9], [4, 9, 25, 1]); };
    expect(badEqualFn).to.throw(SyntaxError);
  });
});
describe('rotation tests', () => {
  it('should do left rotations properly', () => {
    // TODO should also check slotIndex[] before/after
    const tests = [
      { // rotate at left edge
        count:     7,
        slots:     [3, 4, 5, 6, 0, 1, 2],
        slotIndex: [],
        _fromSlot: 0,
        _dist:     1,
        _newSlots: [4, 3, 5, 6, 0, 1, 2],
      },
      { // rotate at right edge
        count:     7,
        slots:     [2, 4, 6, 0, 1, 3, 5],
        slotIndex: [],
        _fromSlot: 5,
        _dist:     1,
        _newSlots: [2, 4, 6, 0, 1, 5, 3],
      },
      { // rotate small in middle
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 2,
        _dist:     2,
        _newSlots: [1, 4, 5, 3, 2, 6, 0],
      },
      { // rotate big in middle
        count:     7,
        slots:     [5, 6, 0, 2, 1, 3, 4],
        slotIndex: [],
        _fromSlot: 1,
        _dist:     4,
        _newSlots: [5, 0, 2, 1, 3, 6, 4],
      },
      { // rotate all
        count:     7,
        slots:     [6, 5, 4, 3, 2, 1, 0],
        slotIndex: [],
        _fromSlot: 0,
        _dist:     6,
        _newSlots: [5, 4, 3, 2, 1, 0, 6],
      },
      { // rotate small across edge
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 6,
        _dist:     1,
        _newSlots: [0, 4, 2, 5, 3, 6, 1],
      },
      { // rotate big across edge
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 5,
        _dist:     3,
        _newSlots: [4, 6, 2, 5, 3, 0, 1],
      },
    ];
    for (const test of tests) {
      grove.rotateLeft(test, test._fromSlot, test._dist);
      expect(test.slots).to.eql(test._newSlots);
    }
  });
  it('should throw exceptions for invalid left rotations', () => {
    const badLowFn = () => { grove.rotateLeft({count: 5}, -1, 2); };
    expect(badLowFn).to.throw(SyntaxError);
    const badHighFn = () => { grove.rotateLeft({count: 5}, 5, 4); };
    expect(badHighFn).to.throw(SyntaxError);
    const badDistFn = () => { grove.rotateLeft({count: 5}, 0, -1); };
    expect(badDistFn).to.throw(SyntaxError);
  });
  it('should do right rotations properly', () => {
    // TODO should also check slotIndex[] before/after
    const tests = [
      { // rotate at left edge
        count:     7,
        slots:     [3, 4, 5, 6, 0, 1, 2],
        slotIndex: [],
        _fromSlot: 1,
        _dist:     -1,
        _newSlots: [4, 3, 5, 6, 0, 1, 2],
      },
      { // rotate at right edge
        count:     7,
        slots:     [2, 4, 6, 0, 1, 3, 5],
        slotIndex: [],
        _fromSlot: 6,
        _dist:     -1,
        _newSlots: [2, 4, 6, 0, 1, 5, 3],
      },
      { // rotate small in middle
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 4,
        _dist:     -2,
        _newSlots: [1, 4, 3, 2, 5, 6, 0],
      },
      { // rotate big in middle
        count:     7,
        slots:     [5, 6, 0, 2, 1, 3, 4],
        slotIndex: [],
        _fromSlot: 5,
        _dist:     -4,
        _newSlots: [5, 3, 6, 0, 2, 1, 4],
      },
      { // rotate all
        count:     7,
        slots:     [6, 5, 4, 3, 2, 1, 0],
        slotIndex: [],
        _fromSlot: 6,
        _dist:     -6,
        _newSlots: [0, 6, 5, 4, 3, 2, 1],
      },
      { // rotate small across edge
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 0,
        _dist:     -2,
        _newSlots: [0, 4, 2, 5, 3, 1, 6],
      },
      { // rotate big across edge
        count:     7,
        slots:     [1, 4, 2, 5, 3, 6, 0],
        slotIndex: [],
        _fromSlot: 1,
        _dist:     -4,
        _newSlots: [0, 1, 2, 5, 4, 3, 6],
      },
    ];
    for (const test of tests) {
      grove.rotateRight(test, test._fromSlot, test._dist);
      expect(test.slots).to.eql(test._newSlots);
    }
  });
  it('should throw exceptions for invalid right rotations', () => {
    const badLowFn = () => { grove.rotateRight({count: 5}, -1, 2); };
    expect(badLowFn).to.throw(SyntaxError);
    const badHighFn = () => { grove.rotateRight({count: 5}, 5, 0); };
    expect(badHighFn).to.throw(SyntaxError);
    const badDistFn = () => { grove.rotateRight({count: 5}, 4, 1); };
    expect(badDistFn).to.throw(SyntaxError);
  });
});
describe('decrypting tests', () => {
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
    for (const expectedNumbers of expected) {
      grove.doMove(state);
      assertRotatedEq(state, expectedNumbers);
    }
  });
  it('should execute each move correctly (Reddit user hugseverycat example)', () => {
    // h/t https://www.reddit.com/r/adventofcode/comments/zr29qd/2022_day_20_part_1_python_hidden_edge_case/j11bcdy/
    const numbers = [0, -1, -1, 1];
    const expected = [-1, 1, -1, 0];
    const state = grove.state(numbers);
    grove.doMoves(state);
    assertRotatedEq(state, expected);
  });
  it('should execute each move correctly (Reddit user 1234abcdcba4321 example)', () => {
    // h/t https://www.reddit.com/r/adventofcode/comments/zr29qd/2022_day_20_part_1_python_hidden_edge_case/j119tzk/
    const numbers = [3, 1, 0];
    const expected = [3, 1, 0];
    const state = grove.state(numbers);
    grove.doMoves(state);
    assertRotatedEq(state, expected);
  });
  it('should find grove coordinates correctly (puzzle example)', () => {
    const numbers = grove.parse(exampleInput);
    const state = grove.state(numbers);
    grove.doMoves(state);
    expect(grove.coordinates(state)).to.eql([4, -3, 2]);
  });
  it('should throw exception if round was incomplete', () => {
    const numbers = grove.parse(exampleInput);
    const state = grove.state(numbers);
    grove.doMove(state);
    const incompleteFn = () => { grove.coordinates(state); };
    expect(incompleteFn).to.throw(SyntaxError);
  });
  it('should find grove coordinates correctly (Reddit user MouseyPounds example)', () => {
    // h/t https://www.reddit.com/r/adventofcode/comments/zr29qd/2022_day_20_part_1_python_hidden_edge_case/j11d86z/
    const numbers = [1, 2, -3, 3, -2, 0, 8];
    const expected = 7;
    const state = grove.state(numbers);
    grove.doMoves(state);
    const actual = grove.coordinates(state).reduce((sum, n) => sum + n, 0);
    expect(actual).to.eql(expected);
  });
});
describe('complex decrypting tests', () => {
  it('should execute each round correctly (puzzle example)', () => {
    const numbers = grove.keyTransform(grove.parse(exampleInput));
    const state = grove.state(numbers);
    const expected = [
      // Initial arrangement:
      [811589153, 1623178306, -2434767459, 2434767459, -1623178306, 0, 3246356612],
      // After 1 round of mixing:
      [0, -2434767459, 3246356612, -1623178306, 2434767459, 1623178306, 811589153],
      // After 2 rounds of mixing:
      [0, 2434767459, 1623178306, 3246356612, -2434767459, -1623178306, 811589153],
      // After 3 rounds of mixing:
      [0, 811589153, 2434767459, 3246356612, 1623178306, -1623178306, -2434767459],
      // After 4 rounds of mixing:
      [0, 1623178306, -2434767459, 811589153, 2434767459, 3246356612, -1623178306],
      // After 5 rounds of mixing:
      [0, 811589153, -1623178306, 1623178306, -2434767459, 3246356612, 2434767459],
      // After 6 rounds of mixing:
      [0, 811589153, -1623178306, 3246356612, -2434767459, 1623178306, 2434767459],
      // After 7 rounds of mixing:
      [0, -2434767459, 2434767459, 1623178306, -1623178306, 811589153, 3246356612],
      // After 8 rounds of mixing:
      [0, 1623178306, 3246356612, 811589153, -2434767459, 2434767459, -1623178306],
      // After 9 rounds of mixing:
      [0, 811589153, 1623178306, -2434767459, 3246356612, 2434767459, -1623178306],
      // After 10 rounds of mixing:
      [0, -2434767459, 1623178306, 3246356612, -1623178306, 2434767459, 811589153],
    ];
    const exp0 = expected.shift();
    expect(grove.currentNumbers(state)).to.eql(exp0);
    for (const expectedNumbers of expected) {
      grove.doMoves(state);
      assertRotatedEq(state, expectedNumbers);
    }
  });
});
