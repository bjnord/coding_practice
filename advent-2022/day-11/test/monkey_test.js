'use strict';
const expect = require('chai').expect;
const monkey = require('../src/monkey');
const fs = require('fs');
const exampleInput = fs.readFileSync('input/example.txt', 'utf8');
describe('parsing tests', () => {
  it('should parse one section correctly', () => {
    const exampleMonkey = exampleInput.split(/\n\n/)[0];
    const expected = {
      n: 0, nInspect: 0,
      items: [79, 98],
      inst: {arg1: null, op: '*', arg2: 19},
      testDiv: 23,
      trueMonkey: 2,
      falseMonkey: 3,
    };
    expect(monkey.parseSection(exampleMonkey)).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    console.debug('** TODO ** parse a whole input set');
  });
});
describe('round tests', () => {
  it('should execute multiply instruction correctly', () => {
    expect(monkey.runInst(79, {arg1: null, op: '*', arg2: 19})).to.equal(1501);
    expect(monkey.runInst(97, {arg1: null, op: '*', arg2: null})).to.equal(9409);
  });
  it('should execute add instruction correctly', () => {
    expect(monkey.runInst(65, {arg1: null, op: '+', arg2: 6})).to.equal(71);
    expect(monkey.runInst(37, {arg1: null, op: '+', arg2: null})).to.equal(74);
  });
  console.debug('** TODO ** test unknown op exception');
  it('should execute one round correctly', () => {
    const monkeys = monkey.parse(exampleInput);
    const expected = [
      [20, 23, 27, 26],
      [2080, 25, 167, 207, 401, 1046],
      [],
      [],
    ];
    monkey.runRound(monkeys, true);
    expect(monkeys.map((m) => m.items)).to.eql(expected);
  });
  it('should execute 20 rounds correctly', () => {
    const monkeys = monkey.parse(exampleInput);
    const expected = [
      [10, 12, 14, 26, 34],
      [245, 93, 53, 199, 115],
      [],
      [],
    ];
    const expInspect = [101, 95, 7, 105];
    const expMostAct = [105, 101];
    for (let i = 0; i < 20; i++) {
      monkey.runRound(monkeys, true);
    }
    expect(monkeys.map((m) => m.items)).to.eql(expected);
    expect(monkeys.map((m) => m.nInspect)).to.eql(expInspect);
    expect(monkey.mostActive(monkeys)).to.eql(expMostAct);
  });
});
