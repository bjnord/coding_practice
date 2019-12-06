'use strict';
const expect = require('chai').expect;
const Orbiter = require('../src/orbiter');
describe('orbiter constructor tests', () => {
  it('should parse 3-letter orbit string correctly', () => {
    const orbiter = new Orbiter('COM)AAA');
    expect(orbiter.name).to.eql('AAA');
    expect(orbiter.parentName).to.eql('COM');
  });
  it('should parse differing-letter orbit string correctly', () => {
    const orbiter = new Orbiter('COM)B');
    expect(orbiter.name).to.eql('B');
    expect(orbiter.parentName).to.eql('COM');
  });
  it('should throw an exception for invalid orbit string [case 1]', () => {
    const call = () => { new Orbiter('C-D'); };
    expect(call).to.throw(Error, 'invalid orbit C-D');
  });
  it('should throw an exception for invalid orbit string [case 2]', () => {
    const call = () => { new Orbiter('COM)E)F'); };
    expect(call).to.throw(Error, 'invalid orbit COM)E)F');
  });
  it('should strip spaces from orbit string', () => {
    const orbiter = new Orbiter(' G)H\n');
    expect(orbiter.name).to.eql('H');
    expect(orbiter.parentName).to.eql('G');
  });
});
