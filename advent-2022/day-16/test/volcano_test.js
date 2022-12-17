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
      {
        name: 'AA',
        rate: 0,
        label: 'AA 0',
        paths: [
          {cost: 1, endName: 'DD'},
          {cost: 1, endName: 'II'},
          {cost: 1, endName: 'BB'},
        ],
      },
      {
        name: 'DD',
        rate: 20,
        label: 'DD 20',
        paths: [
          {cost: 1, endName: 'CC'},
          {cost: 1, endName: 'AA'},
          {cost: 1, endName: 'EE'},
        ],
      },
      {
        name: 'JJ',
        rate: 21,
        label: 'JJ 21',
        paths: [
          {cost: 1, endName: 'II'},
        ],
      },
    ];
    for (const exp of expected) {
      const valve = volcano.valve(exp.name);
      expect(valve.rate()).to.equal(exp.rate);
      expect(valve.label()).to.eql(exp.label);
      expect(volcano.pathsOf(valve)).to.eql(exp.paths);
    }
  });
  it('should start with correct location', () => {
    expect(volcano.currentValve().name()).to.eql('AA');
  });
});
describe('Volcano valve tests', () => {
  it('should start with all valves closed', () => {
    const volcano = new Volcano(exampleInput);
    const nValves = volcano.valves().length;
    expect(volcano.closedValves().length).to.equal(nValves);
  });
  it('should reflect total pressure of open valves', () => {
    const volcano = new Volcano(exampleInput);
    expect(volcano.totalRate()).to.equal(0);
    volcano.valve('BB').open();
    expect(volcano.totalRate()).to.equal(13);
    volcano.valve('CC').open();
    expect(volcano.totalRate()).to.equal(13 + 2);
    volcano.valve('DD').open();
    expect(volcano.totalRate()).to.equal(13 + 2 + 20);
  });
});
describe('Volcano valve opening tests', () => {
  it('should find the next best valve to open', () => {
    const volcano = new Volcano(exampleInput);
    volcano.openBestValve();
    expect(volcano.currentValve().name()).to.equal('DD');
    expect(volcano.totalRate()).to.equal(20);
    volcano.openBestValve();
    expect(volcano.currentValve().name()).to.equal('BB');
    expect(volcano.totalRate()).to.equal(33);
  });
});
