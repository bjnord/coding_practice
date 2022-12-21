'use strict';
const expect = require('chai').expect;
const yell = require('../src/yell');
const exampleInput = 'root: pppw + sjmn\ndbpl: 5\ncczh: sllz + lgvd\nzczc: 2\nptdq: humn - dvpt\ndvpt: 3\nlfqf: 4\nhumn: 5\nljgn: 2\nsjmn: drzm * dbpl\nsllz: 4\npppw: cczh / lfqf\nlgvd: ljgn * ptdq\ndrzm: hmdt - zczc\nhmdt: 32\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(yell.parseLine('root: pppw + sjmn')).to.eql({name: 'root', arg1: 'pppw', op: '+', arg2: 'sjmn'});
    expect(yell.parseLine('dbpl: 5')).to.eql({name: 'dbpl', number: 5});
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
});
