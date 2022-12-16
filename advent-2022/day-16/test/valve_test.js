'use strict';
const expect = require('chai').expect;
const Valve = require('../src/valve');
const exampleLine = 'Valve BB has flow rate=13; tunnels lead to valves CC, AA';
describe('Valve constructor tests', () => {
  let valve;
  before(() => {
    valve = new Valve(exampleLine);
  });
  it('should parse example line correctly', () => {
    const expected = {
      name: 'BB',
      rate: 13,
      tunnels: ['CC', 'AA'],
      label: 'BB 13',
    };
    expect(valve.name()).to.equal(expected.name);
    expect(valve.rate()).to.equal(expected.rate);
    expect(valve.tunnels()).to.eql(expected.tunnels);
    expect(valve.label()).to.eql(expected.label);
  });
});
describe('Valve state tests', () => {
  let valve;
  before(() => {
    valve = new Valve(exampleLine);
  });
  it('should report correct valve state', () => {
    expect(valve.isClosed()).to.equal(true);
    expect(valve.isOpen()).to.equal(false);
    valve.open();
    expect(valve.isClosed()).to.equal(false);
    expect(valve.isOpen()).to.equal(true);
  });
});
