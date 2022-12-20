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
