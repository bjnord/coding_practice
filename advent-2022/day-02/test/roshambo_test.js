'use strict';
const expect = require('chai').expect;
const roshambo = require('../src/roshambo');
const exampleInput = 'A Y\nB X\nC Z\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(roshambo.parseLine('A Y')).to.eql({opponent: 0, player: 1});
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {opponent: 0, player: 1},
      {opponent: 1, player: 0},
      {opponent: 2, player: 2},
    ];
    expect(roshambo.parse(exampleInput)).to.eql(expected);
  });
});
