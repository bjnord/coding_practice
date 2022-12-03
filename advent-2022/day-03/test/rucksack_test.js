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
describe('analysis tests', () => {
  it('should determine rucksack common item correctly', () => {
    const rucksacks = rucksack.parse(exampleInput);
    const expected = ['p', 'L', 'P', 'v', 't', 's'];
    const actual = rucksacks.map((ruck) => rucksack.commonItem(ruck));
    expect(actual).to.eql(expected);
  });
  it('should compute rucksack item priority correctly', () => {
    const items = ['p', 'L', 'P', 'v', 't', 's'];
    const expected = [16, 38, 42, 22, 20, 19];
    const actual = items.map((ch) => rucksack.itemPriority(ch));
    expect(actual).to.eql(expected);
  });
});
