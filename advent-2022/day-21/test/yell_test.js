'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const yell = require('../src/yell');
const exampleInput = 'root: pppw + sjmn\ndbpl: 5\ncczh: sllz + lgvd\nzczc: 2\nptdq: humn - dvpt\ndvpt: 3\nlfqf: 4\nhumn: 5\nljgn: 2\nsjmn: drzm * dbpl\nsllz: 4\npppw: cczh / lfqf\nlgvd: ljgn * ptdq\ndrzm: hmdt - zczc\nhmdt: 32\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(yell.parseLine('root: pppw + sjmn')).to.eql({name: 'root', arg1: 'pppw', op: '+', arg2: 'sjmn'});
    expect(yell.parseLine('dbpl: 5')).to.eql({name: 'dbpl', number: 5});
  });
  it('should throw exception for bad line (no job)', () => {
    const badLineFn = () => { yell.parseLine('root'); };
    expect(badLineFn).to.throw(SyntaxError);
  });
  it('should throw exception for bad line (no op)', () => {
    const badLineFn = () => { yell.parseLine('root: pppw + '); };
    expect(badLineFn).to.throw(SyntaxError);
  });
  it('should parse a whole input set correctly', () => {
    const monkeys = yell.parse(exampleInput);
    expect(monkeys.length).to.equal(15);
    const numberMonkeys = monkeys.filter((monkey) => monkey.number !== undefined);
    expect(numberMonkeys.length).to.equal(8);
    expect(numberMonkeys.map((monkey) => monkey.number)).to.eql([5, 2, 3, 4, 5, 2, 4, 32]);
    const equationMonkeys = monkeys.filter((monkey) => monkey.number === undefined);
    expect(equationMonkeys.length).to.equal(7);
    expect(equationMonkeys.map((monkey) => monkey.op)).to.eql(['+', '+', '-', '*', '/', '*', '-']);
  });
});
describe('yelling tests', () => {
  it('should calculate what the root monkey yells correctly', () => {
    const monkeys = yell.parse(exampleInput);
    const monkeyNumbers = yell.monkeyNumbers(monkeys);
    expect(monkeyNumbers['root']).to.equal(152);
  });
  it('should throw exception for bad op (root monkey)', () => {
    const badOpInput = 'root: humn ^ dbpl\ndbpl: 5\nhumn: 5\n';
    const monkeys = yell.parse(badOpInput);
    const badOpFn = () => { yell.monkeyNumbers(monkeys); };
    expect(badOpFn).to.throw(SyntaxError);
  });
  it('should calculate what the human yells correctly', () => {
    const monkeys = yell.parse(exampleInput);
    yell.monkeyNumbers(monkeys);
    expect(yell.humanYell(monkeys)).to.equal(301);
  });
  it('should calculate what the human yells correctly (root flip)', () => {
    const rootFlipInput = exampleInput.replace('root: pppw + sjmn', 'root: sjmn + pppw');
    const monkeys = yell.parse(rootFlipInput);
    yell.monkeyNumbers(monkeys);
    expect(yell.humanYell(monkeys)).to.equal(301);
  });
  it('should calculate what the human yells correctly (commutative)', () => {
    const commutative = [
      'root: juli + josi',
      'juli: amee + alex',
      'amee: buki * abby',
      'buki: 5',
      'abby: 4',
      'alex: 4',
      'josi: benj / mark',
      'benj: 360',
      'mark: emly - humn',
      'emly: 34',
      'humn: 0',
    ];
    const commutativeInput = commutative.join('\n') + '\n';
    const monkeys = yell.parse(commutativeInput);
    yell.monkeyNumbers(monkeys);
    expect(yell.humanYell(monkeys)).to.equal(19);
  });
  it('should calculate what the human yells correctly (Reddit user Cue_23 example)', () => {
    // h/t https://www.reddit.com/r/adventofcode/comments/zrtw6y/2022_day_21_part_2_another_example/j14zz01/
    const cue23Input = fs.readFileSync('input/Cue_23.txt', 'utf8');
    const monkeys = yell.parse(cue23Input);
    yell.monkeyNumbers(monkeys);
    expect(yell.humanYell(monkeys)).to.equal(19);
  });
  it('should throw exception if prereq function not called', () => {
    const monkeys = yell.parse(exampleInput);
    const noPrereqFn = () => { yell.humanYell(monkeys); };
    expect(noPrereqFn).to.throw(SyntaxError);
  });
});
