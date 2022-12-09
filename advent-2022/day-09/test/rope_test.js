'use strict';
const expect = require('chai').expect;
const rope = require('../src/rope');
const exampleInput = 'R 4\nU 4\nL 3\nD 1\nR 4\nD 1\nL 5\nR 2\n';
const exampleInput2 = 'R 5\nU 8\nL 8\nD 3\nR 17\nD 10\nL 25\nU 20\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(rope.parseLine('R 4')).to.eql(['R', 4]);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      ['R', 4],
      ['U', 4],
      ['L', 3],
      ['D', 1],
      ['R', 4],
      ['D', 1],
      ['L', 5],
      ['R', 2],
    ];
    expect(rope.parse(exampleInput)).to.eql(expected);
  });
});
describe('motion tests', () => {
  it('should follow 2-knot motions and report positions visited', () => {
    const motions = rope.parse(exampleInput);
    expect(rope.followMotions(motions)).to.equal(13);
  });
  it('should follow 10-knot motions and report positions visited', () => {
    const dumpGrid = {y0: -4, y1: 0, x0: 0, x1: 5, all: true};
    const motions = rope.parse(exampleInput);
    expect(rope.followMotions10(motions, null)).to.equal(1);
    const dumpGrid2 = {y0: -15, y1: 5, x0: -11, x1: 14, all: false};
    const motions2 = rope.parse(exampleInput2);
    expect(rope.followMotions10(motions2, null)).to.equal(36);
  });
});
