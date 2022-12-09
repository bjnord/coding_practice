'use strict';
const expect = require('chai').expect;
const rope = require('../src/rope');
const exampleInput = 'R 4\nU 4\nL 3\nD 1\nR 4\nD 1\nL 5\nR 2\n';
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
