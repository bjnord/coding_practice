'use strict';
const expect = require('chai').expect;
const roshambo = require('../src/roshambo');
const exampleInput = 'A Y\nB X\nC Z\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(roshambo.parseLine('A Y')).to.eql({opponent: 'A', player: 'Y'});
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {opponent: 'A', player: 'Y'},
      {opponent: 'B', player: 'X'},
      {opponent: 'C', player: 'Z'},
    ];
    expect(roshambo.parse(exampleInput)).to.eql(expected);
  });
});
