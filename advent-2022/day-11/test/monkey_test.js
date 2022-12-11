'use strict';
const expect = require('chai').expect;
const monkey = require('../src/monkey');
const fs = require('fs');
const exampleInput = fs.readFileSync('input/example.txt', 'utf8');
describe('parsing tests', () => {
  it('should parse one section correctly', () => {
    const exampleMonkey = exampleInput.split(/\n\n/)[0];
    const expected = {
      n: 0,
      items: [79, 98],
      inst: {arg1: null, op: '*', arg2: 19},
      testDiv: 23,
      trueMonkey: 2,
      falseMonkey: 3,
    };
    expect(monkey.parseSection(exampleMonkey)).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    console.debug('** TODO **');
  });
});
