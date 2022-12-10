'use strict';
const expect = require('chai').expect;
const processor = require('../src/processor');
const fs = require('fs');
const exampleInput = 'noop\naddx 3\naddx -5\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(processor.parseLine('addx 3')).to.eql({op: 'addx', arg: 3});
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {op: 'noop'},
      {op: 'addx', arg: 3},
      {op: 'addx', arg: -5},
    ];
    expect(processor.parse(exampleInput)).to.eql(expected);
  });
});
describe('execution tests', () => {
  it('should find the six signal strengths correctly', () => {
    const longInput = fs.readFileSync('input/example.txt', 'utf8');
    const longProgram = processor.parse(longInput);
    const expected = [
      420,
      1140,
      1800,
      2940,
      2880,
      3960,
    ];
    expect(processor.signalStrengths(longProgram)).to.eql(expected);
  });
});
