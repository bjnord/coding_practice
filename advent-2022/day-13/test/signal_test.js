'use strict';
const expect = require('chai').expect;
const signal = require('../src/signal');
const exampleInput = '[1,1,3,1,1]\n[1,1,5,1,1]\n\n[[1],[2,3,4]]\n[[1],4]\n\n[9]\n[[8,7,6]]\n\n[[4,4],4,4]\n[[4,4],4,4,4]\n\n[7,7,7,7]\n[7,7,7]\n\n[]\n[3]\n\n[[[]]]\n[[]]\n\n[1,[2,[3,[4,[5,6,7]]]],8,9]\n[1,[2,[3,[4,[5,6,0]]]],8,9]\n';
describe('parsing tests', () => {
  it('should parse one pair correctly (flat)', () => {
    const expected = {
      left: [1, 1, 3, 1, 1],
      right: [1, 1, 5, 1, 1],
    };
    expect(signal.parsePair('[1,1,3,1,1]\n[1,1,5,1,1]')).to.eql(expected);
  });
  it('should parse one pair correctly (single-level nested)', () => {
    const expected = {
      left: [[1], [2, 3, 4]],
      right: [[1], 4],
    };
    expect(signal.parsePair('[[1],[2,3,4]]\n[[1],4]')).to.eql(expected);
  });
  it('should parse one pair correctly (multi-level nested)', () => {
    const expected = {
      left: [1, [2, [3, [4, [5, 6, 7]]]], 8, 9],
      right: [1, [2, [3, [4, [5, 6, 0]]]], 8, 9],
    };
    expect(signal.parsePair('[1,[2,[3,[4,[5,6,7]]]],8,9]\n[1,[2,[3,[4,[5,6,0]]]],8,9]')).to.eql(expected);
  });
});
