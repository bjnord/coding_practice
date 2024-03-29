'use strict';
const expect = require('chai').expect;
const food = require('../src/food');
const exampleInput = '1000\n2000\n3000\n\n4000\n\n5000\n6000\n\n7000\n8000\n9000\n\n10000\n';
describe('parsing tests', () => {
  it('should parse one subsection correctly', () => {
    const expected = [
      7000,
      8000,
      9000,
    ];
    expect(food.parseSection('7000\n8000\n9000')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      [1000, 2000, 3000],
      [4000],
      [5000, 6000],
      [7000, 8000, 9000],
      [10000],
    ];
    expect(food.parse(exampleInput)).to.eql(expected);
  });
});
describe('elf section/item tests', () => {
  it('should sum and sort sections correctly', () => {
    const sections = food.parse(exampleInput);
    const expected = [
      24000,
      11000,
      10000,
    ];
    const actual = food.totalCaloriesSorted(sections).slice(0, 3);
    expect(actual).to.eql(expected);
  });
});
