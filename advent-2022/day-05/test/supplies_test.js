'use strict';
const expect = require('chai').expect;
const supplies = require('../src/supplies');
const exampleInput = '    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 \n\nmove 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\n move 1 from 1 to 2\n';
describe('parsing tests', () => {
  it('should parse crates correctly', () => {
    const expected = [
      ['Z', 'N'],
      ['M', 'C', 'D'],
      ['P'],
    ];
    expect(supplies.parseCrates(exampleInput)).to.eql(expected);
  });
  it('should parse steps correctly', () => {
    const expected = [
      [1, 2, 1],
      [3, 1, 3],
      [2, 2, 1],
      [1, 1, 2],
    ];
    expect(supplies.parseSteps(exampleInput)).to.eql(expected);
  });
});
describe('procedure tests (style 1)', () => {
  it('should move crates correctly', () => {
    const crates = supplies.parseCrates(exampleInput);
    const steps = supplies.parseSteps(exampleInput);
    const expected = 'CMZ';
    expect(supplies.moveCrates(crates, steps)).to.equal(expected);
  });
});
describe('procedure tests (style 2)', () => {
  it('should multi-move crates correctly', () => {
    const crates = supplies.parseCrates(exampleInput);
    const steps = supplies.parseSteps(exampleInput);
    const expected = 'MCD';
    expect(supplies.multiMoveCrates(crates, steps)).to.equal(expected);
  });
});
