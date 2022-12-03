'use strict';
const expect = require('chai').expect;
const rucksack = require('../src/rucksack');
const exampleInput = 'vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const expected = [
      'vJrwpWtwJgWr',
      'hcsFMMfFFhFp',
    ];
    expect(rucksack.parseLine('vJrwpWtwJgWrhcsFMMfFFhFp')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      ['vJrwpWtwJgWr', 'hcsFMMfFFhFp'],
      ['jqHRNqRjqzjGDLGL', 'rsFMfFZSrLrFZsSL'],
      ['PmmdzqPrV', 'vPwwTWBwg'],
      ['wMqvLMZHhHMvwLH', 'jbvcjnnSBnvTQFn'],
      ['ttgJtRGJ', 'QctTZtZT'],
      ['CrZsJsPPZsGz', 'wwsLwLmpwMDw'],
    ];
    expect(rucksack.parse(exampleInput)).to.eql(expected);
  });
});
