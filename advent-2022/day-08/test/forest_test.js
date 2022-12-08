'use strict';
const expect = require('chai').expect;
const forest = require('../src/forest');
const exampleInput = '30373\n25512\n65332\n33549\n35390\n';
describe('parsing tests', () => {
  it('should parse a whole input set correctly', () => {
    const expected = [
      [3, 0, 3, 7, 3],
      [2, 5, 5, 1, 2],
      [6, 5, 3, 3, 2],
      [3, 3, 5, 4, 9],
      [3, 5, 3, 9, 0],
    ];
    expect(forest.parse(exampleInput)).to.eql(expected);
  });
});
