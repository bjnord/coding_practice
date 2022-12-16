'use strict';
const expect = require('chai').expect;
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
describe('Volcano constructor tests', () => {
  let volcano;
  before(() => {
    volcano = new Volcano(exampleInput);
    volcano.writeGraph('graph/example.mermaid');
  });
  it('should parse example input correctly', () => {
    const expected = [
      {name: 'AA', rate: 0, tunnels: ['DD', 'II', 'BB'], label: 'AA 0'},
      {name: 'DD', rate: 20, tunnels: ['CC', 'AA', 'EE'], label: 'DD 20'},
      {name: 'JJ', rate: 21, tunnels: ['II'], label: 'JJ 21'},
    ];
    for (const exp of expected) {
      expect(volcano.valve(exp.name).rate()).to.equal(exp.rate);
      expect(volcano.valve(exp.name).tunnels()).to.eql(exp.tunnels);
      expect(volcano.valve(exp.name).label()).to.eql(exp.label);
    }
  });
});
describe('Volcano valve state tests', () => {
  let volcano;
  before(() => {
    volcano = new Volcano(exampleInput);
  });
  it('should start with all valves closed', () => {
    const nValves = volcano.valves().length;
    expect(volcano.closedValves().length).to.equal(nValves);
  });
});
