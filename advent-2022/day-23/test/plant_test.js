'use strict';
const expect = require('chai').expect;
const plant = require('../src/plant');
const smallExInput = '.....\n..##.\n..#..\n.....\n..##.\n.....\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(plant.parseLine('.##..')).to.eql([false, true, true, false, false]);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {y: -1, x: 2},
      {y: -1, x: 3},
      {y: -2, x: 2},
      {y: -4, x: 2},
      {y: -4, x: 3},
    ];
    expect(plant.parse(smallExInput)).to.eql(expected);
  });
});
