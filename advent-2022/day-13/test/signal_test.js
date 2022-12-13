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
describe('comparison tests', () => {
  it('should compare two integers correctly', () => {
    expect(signal.compare(1, 2)).to.equal(-1);
    expect(signal.compare(3, 3)).to.equal(0);
    expect(signal.compare(-1, -2)).to.equal(1);
  });
  it('should compare two lists correctly (flat)', () => {
    expect(signal.compare([1, 2, 3], [1, 3, 3])).to.equal(-1);
    expect(signal.compare([1, 2, 3], [1, 2, 3])).to.equal(0);
    expect(signal.compare([1, 3, 4], [1, 2, 3])).to.equal(1);
  });
  it('should compare two lists correctly (mixed)', () => {
    expect(signal.compare([1, 2, 3], 2)).to.equal(-1);
    expect(signal.compare([3, 4, 6], 2)).to.equal(1);
  });
  it('should compare a pair correctly (example pair 2)', () => {
    const pair2 = signal.parsePair('[[1],[2,3,4]]\n[[1],4]');
    expect(signal.compare(pair2.left, pair2.right)).to.equal(-1);
  });
  it('should compare a pair correctly (example pair 3)', () => {
    const pair3 = signal.parsePair('[9]\n[[8,7,6]]');
    expect(signal.compare(pair3.left, pair3.right)).to.equal(1);
  });
  it('should compare all pairs correctly', () => {
    const pairs = signal.parse(exampleInput);
    const expected = [-1, -1, 1, -1, 1, -1, 1, 1];
    expect(signal.comparePairs(pairs)).to.eql(expected);
  });
});
