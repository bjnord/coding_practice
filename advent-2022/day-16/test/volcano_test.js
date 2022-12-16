'use strict';
const expect = require('chai').expect;
const Valve = require('../src/valve');
const Volcano = require('../src/volcano');
const exampleInput = `Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
`;
describe('constructor tests', () => {
  let volcano;
  before(() => {
    volcano = new Volcano(exampleInput);
  });
  it('should parse example input correctly', () => {
    const expected = [
      {name: 'AA', rate: 0, tunnels: ['DD', 'II', 'BB']},
      {name: 'DD', rate: 20, tunnels: ['CC', 'AA', 'EE']},
      {name: 'JJ', rate: 21, tunnels: ['II']},
    ];
    for (const exp of expected) {
      expect(volcano.valve(exp.name).rate()).to.equal(exp.rate);
      expect(volcano.valve(exp.name).tunnels()).to.eql(exp.tunnels);
    }
  });
});
