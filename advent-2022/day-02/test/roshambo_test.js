'use strict';
const expect = require('chai').expect;
const roshambo = require('../src/roshambo');
const exampleInput = 'A Y\nB X\nC Z\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(roshambo.parseLine('A Y')).to.eql({opponent: 0, player: 1});
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {opponent: 0, player: 1},
      {opponent: 1, player: 0},
      {opponent: 2, player: 2},
    ];
    expect(roshambo.parse(exampleInput)).to.eql(expected);
  });
});
describe('outcome tests', () => {
  it('should declare a win correctly', () => {
    const round = roshambo.parseLine('A Y');
    expect(roshambo.outcomeForPlay(round)).to.eql(2);
  });
  it('should declare a wrap-win correctly', () => {
    const round = roshambo.parseLine('C X');
    expect(roshambo.outcomeForPlay(round)).to.eql(2);
  });
  it('should declare a loss correctly', () => {
    const round = roshambo.parseLine('B X');
    expect(roshambo.outcomeForPlay(round)).to.eql(0);
  });
  it('should declare a wrap-loss correctly', () => {
    const round = roshambo.parseLine('A Z');
    expect(roshambo.outcomeForPlay(round)).to.eql(0);
  });
  it('should declare a draw correctly', () => {
    const round = roshambo.parseLine('C Z');
    expect(roshambo.outcomeForPlay(round)).to.eql(1);
  });
});
describe('scoring tests (strategy type 1)', () => {
  it('should score a win correctly', () => {
    const round = roshambo.parseLine('A Y');
    expect(roshambo.score(round)).to.eql(2 + 6);
  });
  it('should score a wrap-win correctly', () => {
    const round = roshambo.parseLine('C X');
    expect(roshambo.score(round)).to.eql(1 + 6);
  });
  it('should score a loss correctly', () => {
    const round = roshambo.parseLine('B X');
    expect(roshambo.score(round)).to.eql(1 + 0);
  });
  it('should score a wrap-loss correctly', () => {
    const round = roshambo.parseLine('A Z');
    expect(roshambo.score(round)).to.eql(3 + 0);
  });
  it('should score a draw correctly', () => {
    const round = roshambo.parseLine('C Z');
    expect(roshambo.score(round)).to.eql(3 + 3);
  });
  it('should compute total score correctly', () => {
    const rounds = roshambo.parse(exampleInput);
    expect(roshambo.scoreRounds(rounds)).to.eql(15);
  });
});
describe('play tests', () => {
  it('should choose shape for a draw correctly', () => {
    const round = roshambo.parseLine('A Y');
    expect(roshambo.playForOutcome(round)).to.eql(0);
  });
  it('should choose shape for a loss correctly', () => {
    const round = roshambo.parseLine('B X');
    expect(roshambo.playForOutcome(round)).to.eql(0);
  });
  it('should choose shape for a win correctly', () => {
    const round = roshambo.parseLine('C Z');
    expect(roshambo.playForOutcome(round)).to.eql(0);
  });
});
describe('scoring tests (strategy type 2)', () => {
  it('should score a draw correctly', () => {
    const round = roshambo.parseLine('A Y');
    expect(roshambo.score2(round)).to.eql(1 + 3);
  });
  it('should score a loss correctly', () => {
    const round = roshambo.parseLine('B X');
    expect(roshambo.score2(round)).to.eql(1 + 0);
  });
  it('should score a win correctly', () => {
    const round = roshambo.parseLine('C Z');
    expect(roshambo.score2(round)).to.eql(1 + 6);
  });
  it('should compute total score correctly', () => {
    const rounds = roshambo.parse(exampleInput);
    expect(roshambo.scoreRounds2(rounds)).to.eql(12);
  });
});
