'use strict';
const expect = require('chai').expect;
const rucksack = require('../src/rucksack');
const exampleInput = 'vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const expected = [
      { 'J': true, 'W': true, 'g': true, 'p': true,
        'r': true, 't': true, 'v': true, 'w': true, },
      { 'F': true, 'M': true, 'c': true, 'f': true,
        'h': true, 'p': true, 's': true, },
    ];
    expect(rucksack.parseLine('vJrwpWtwJgWrhcsFMMfFFhFp')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      [
        { 'J': true, 'W': true, 'g': true, 'p': true,
          'r': true, 't': true, 'v': true, 'w': true, },
        { 'F': true, 'M': true, 'c': true, 'f': true,
          'h': true, 'p': true, 's': true, },
      ],
      [
        { 'D': true, 'G': true, 'H': true, 'L': true,
          'N': true, 'R': true, 'j': true, 'q': true,
          'z': true, },
        { 'F': true, 'L': true, 'M': true, 'S': true,
          'Z': true, 'f': true, 'r': true, 's': true, },
      ],
      [
        { 'P': true, 'V': true, 'd': true, 'm': true,
          'q': true, 'r': true, 'z': true, },
        { 'B': true, 'P': true, 'T': true, 'W': true,
          'g': true, 'v': true, 'w': true, }
      ],
      [
        { 'H': true, 'L': true, 'M': true, 'Z': true,
          'h': true, 'q': true, 'v': true, 'w': true, },
        { 'B': true, 'F': true, 'Q': true, 'S': true,
          'T': true, 'b': true, 'c': true, 'j': true,
          'n': true, 'v': true, },
      ],
      [
        { 'G': true, 'J': true, 'R': true, 'g': true,
          't': true, },
        { 'Q': true, 'T': true, 'Z': true, 'c': true,
          't': true, },
      ],
      [
        { 'C': true, 'G': true, 'J': true, 'P': true,
          'Z': true, 'r': true, 's': true, 'z': true, },
        { 'D': true, 'L': true, 'M': true, 'm': true,
          'p': true, 's': true, 'w': true, },
      ],
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
describe('rucksack group tests', () => {
  it('should determine rucksack group common item correctly', () => {
    const rucksacks = rucksack.parse(exampleInput);
    const expected = ['r', 'Z'];
    expect(rucksack.commonItems3(rucksacks)).to.eql(expected);
  });
});
