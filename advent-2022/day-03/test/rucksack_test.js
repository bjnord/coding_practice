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
      { 'F': true, 'J': true, 'M': true, 'W': true,
        'c': true, 'f': true, 'g': true, 'h': true,
        'p': true, 'r': true, 's': true, 't': true,
        'v': true, 'w': true, },
    ];
    expect(rucksack.parseLine('vJrwpWtwJgWrhcsFMMfFFhFp')).to.eql(expected);
  });
  it('should throw exception for odd-sized line', () => {
    const oddParseFn = () => { rucksack.parseLine('AbcdEfg'); };
    expect(oddParseFn).to.throw(SyntaxError);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      { 'J': true, 'W': true, 'g': true, 'p': true,
        'r': true, 't': true, 'v': true, 'w': true, },
      { 'D': true, 'G': true, 'H': true, 'L': true,
        'N': true, 'R': true, 'j': true, 'q': true,
        'z': true, },
      { 'P': true, 'V': true, 'd': true, 'm': true,
        'q': true, 'r': true, 'z': true, },
      { 'H': true, 'L': true, 'M': true, 'Z': true,
        'h': true, 'q': true, 'v': true, 'w': true, },
      { 'G': true, 'J': true, 'R': true, 'g': true,
        't': true, },
      { 'C': true, 'G': true, 'J': true, 'P': true,
        'Z': true, 'r': true, 's': true, 'z': true, },
    ];
    const actual = rucksack.parse(exampleInput).map((ruck) => ruck[0]);
    expect(actual).to.eql(expected);
  });
});
describe('analysis tests', () => {
  it('should determine rucksack common item correctly', () => {
    const rucksacks = rucksack.parse(exampleInput);
    const expected = ['p', 'L', 'P', 'v', 't', 's'];
    const actual = rucksacks.map((ruck) => rucksack.commonItem(ruck));
    expect(actual).to.eql(expected);
  });
  it('should throw exception if no common item found', () => {
    const ruck = rucksack.parseLine('AbcdEfgh');
    const noCommonFn = () => { rucksack.commonItem(ruck); };
    expect(noCommonFn).to.throw(SyntaxError);
  });
  it('should throw exception if multiple common items found', () => {
    const ruck = rucksack.parseLine('AbcdEcfb');
    const multiCommonFn = () => { rucksack.commonItem(ruck); };
    expect(multiCommonFn).to.throw(SyntaxError);
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
