'use strict';
const expect = require('chai').expect;
const bugs = require('../src/bugs');

const states = [{state: 0b0000100100110010100110000, lines: [
  '....#',
  '#..#.',
  '#..##',
  '..#..',
  '#....',
]}, {state: 0b0011011011101110111101001, lines: [
  '#..#.',
  '####.',
  '###.#',
  '##.##',
  '.##..',
]}, {state: 0b1110101000100001000011111, lines: [
  '#####',
  '....#',
  '....#',
  '...#.',
  '#.###',
]}, {state: 0b1011001101110000111100001, lines: [
  '#....',
  '####.',
  '...##',
  '#.##.',
  '.##.#',
]}, {state: 0b0001100000100111000001111, lines: [
  '####.',
  '....#',
  '##..#',
  '.....',
  '##...',
]}];
const repeatedState = {state: 0b0001000001000000000000000, lines: [
  '.....',
  '.....',
  '.....',
  '#....',
  '.#...',
]};

describe('bugs parse tests [puzzle example]', () => {
  it('parses all states correctly', () => {
    for (let i = 0; i < states.length; i++) {
      expect(bugs.parse(states[i].lines)).to.eql(states[i].state);
    }
  });
  it('parses the repeated state correctly', () => {
    expect(bugs.parse(repeatedState.lines)).to.eql(repeatedState.state);
  });
  it('parses an invalid grid as expected', () => {
    const badLines = [
      '.....',
      '... .',
      '.....',
      '#....',
      '.#...',
    ];
    expect(bugs.parse(badLines)).to.be.NaN;
  });
});
describe('bugs format tests [puzzle example]', () => {
  it('formats all states correctly', () => {
    for (let i = 0; i < states.length; i++) {
      expect(bugs.format(states[i].state)).to.eql(states[i].lines);
    }
  });
  it('formats the repeated state correctly', () => {
    expect(bugs.format(repeatedState.state)).to.eql(repeatedState.lines);
  });
});
describe('bugs count tests [puzzle example]', () => {
  it('counts bugs in the middle correctly', () => {
    expect(bugs.count(states[1].state, [1, 1])).to.eql(3);
    expect(bugs.count(states[1].state, [1, 3])).to.eql(2);
    expect(bugs.count(states[1].state, [3, 2])).to.eql(4);
    expect(bugs.count(states[1].state, [3, 3])).to.eql(1);
  });
  it('counts bugs at the edges correctly', () => {
    expect(bugs.count(states[1].state, [0, 1])).to.eql(2);
    expect(bugs.count(states[1].state, [1, 4])).to.eql(2);
    expect(bugs.count(states[1].state, [4, 3])).to.eql(2);
    expect(bugs.count(states[1].state, [3, 0])).to.eql(2);
  });
  it('counts bugs at the corners correctly', () => {
    expect(bugs.count(states[1].state, [0, 0])).to.eql(1);
    expect(bugs.count(states[1].state, [0, 4])).to.eql(1);
    expect(bugs.count(states[1].state, [4, 0])).to.eql(2);
    expect(bugs.count(states[1].state, [4, 4])).to.eql(1);
  });
});
describe('bugs event tests [puzzle example]', () => {
  it('gets the correct event for empty squares at edges', () => {
    expect(bugs.event(states[3].state, [0, 2])).to.eql('spawn');
    expect(bugs.event(states[3].state, [1, 4])).to.eql('spawn');
    expect(bugs.event(states[3].state, [3, 4])).to.eql('stasis');
  });
  it('gets the correct event for bugs at edges', () => {
    expect(bugs.event(states[3].state, [1, 0])).to.eql('death');
    expect(bugs.event(states[3].state, [3, 0])).to.eql('death');
    expect(bugs.event(states[3].state, [2, 4])).to.eql('stasis');
  });
  it('gets the correct event for empty squares at corners', () => {
    expect(bugs.event(states[3].state, [0, 4])).to.eql('stasis');
    expect(bugs.event(states[3].state, [4, 0])).to.eql('spawn');
  });
  it('gets the correct event for bugs at corners', () => {
    expect(bugs.event(states[3].state, [0, 0])).to.eql('stasis');
    expect(bugs.event(states[3].state, [4, 4])).to.eql('death');
  });
  it('gets the correct event for empty squares in the middle', () => {
    expect(bugs.event(states[3].state, [2, 1])).to.eql('spawn');
    expect(bugs.event(states[3].state, [2, 2])).to.eql('stasis');
    expect(bugs.event(states[3].state, [3, 1])).to.eql('stasis');
  });
  it('gets the correct event for bugs in the middle', () => {
    expect(bugs.event(states[3].state, [1, 1])).to.eql('death');
    expect(bugs.event(states[3].state, [1, 3])).to.eql('death');
    expect(bugs.event(states[3].state, [2, 3])).to.eql('death');
    expect(bugs.event(states[3].state, [3, 2])).to.eql('death');
  });
});
describe('bugs generate tests [puzzle example]', () => {
  it('gets each state correctly from the previous one', () => {
    let currentState = states[0].state;
    for (let i = 1; i < states.length-1; i++) {
      const expectedState = states[i].state;
      const nextState = bugs.generate(currentState);
      //console.debug('expected:');
      //bugs.format(expectedState).forEach((line) => console.debug(line));
      //console.debug('actual:');
      //bugs.format(nextState).forEach((line) => console.debug(line));
      //console.debug(`test state ${i-1} expected=0x${expectedState.toString(2).padStart('0', 25)}`);
      //console.debug(`test state ${i-1}   actual=0x${nextState.toString(2).padStart('0', 25)}`);
      expect(nextState).to.eql(expectedState);
      currentState = nextState;
    }
  });
});
describe('bugs iterate tests [puzzle example]', () => {
  it('reaches the final repeated state correctly', () => {
    expect(bugs.iterate(states[0].state)).to.eql(repeatedState.state);
  });
});
describe('bugs biodiversity rating tests [puzzle example]', () => {
  it('gets the correct biodiversity rating', () => {
    expect(repeatedState.state).to.eql(2129920);  // how convenient!
  });
});
