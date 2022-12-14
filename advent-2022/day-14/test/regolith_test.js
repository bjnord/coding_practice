'use strict';
const expect = require('chai').expect;
const regolith = require('../src/regolith');
const exampleInput = '498,4 -> 498,6 -> 496,6\n503,4 -> 502,4 -> 502,9 -> 494,9';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const expected = [
      {y: 4, x: 498}, {y: 6, x: 498}, {y: 6, x: 496}
    ];
    expect(regolith.parseLine('498,4 -> 498,6 -> 496,6')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      [{y: 4, x: 498}, {y: 6, x: 498}, {y: 6, x: 496}],
      [{y: 4, x: 503}, {y: 4, x: 502}, {y: 9, x: 502}, {y: 9, x: 494}],
    ];
    expect(regolith.parse(exampleInput)).to.eql(expected);
  });
});
