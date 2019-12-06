'use strict';
const expect = require('chai').expect;
const OrbitMap = require('../src/orbit_map');
describe('orbit map constructor tests', () => {
  it('should parse 3-level orbit map correctly', () => {
    const orbitMap = new OrbitMap('A)B\nCOM)A\nA)C');
    expect(orbitMap.directOrbitCount).to.eql(3);
    expect(orbitMap.parentOf('C')).to.eql('A');
    expect(orbitMap.parentOf('A')).to.eql('COM');
    expect(orbitMap.parentOf('COM')).to.be.undefined;
  });
  it('should parse puzzle example orbit map correctly', () => {
    const orbitMap = new OrbitMap('COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\n');
    expect(orbitMap.directOrbitCount).to.eql(11);
    expect(orbitMap.parentOf('H')).to.eql('G');
    expect(orbitMap.parentOf('G')).to.eql('B');
    expect(orbitMap.parentOf('B')).to.eql('COM');
    expect(orbitMap.parentOf('COM')).to.be.undefined;
  });
});
describe('orbit map count tests', () => {
  it('should count orbits in 3-level orbit map correctly', () => {
    const orbitMap = new OrbitMap('A)B\nCOM)A\nA)C');
    expect(orbitMap.totalOrbitCountOf('A')).to.eql(1);
    expect(orbitMap.totalOrbitCountOf('B')).to.eql(2);
    expect(orbitMap.totalOrbitCount).to.eql(5);
  });
  it('should count orbits in puzzle example orbit map correctly', () => {
    const orbitMap = new OrbitMap('COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\n');
    expect(orbitMap.totalOrbitCountOf('D')).to.eql(3);
    expect(orbitMap.totalOrbitCountOf('L')).to.eql(7);
    expect(orbitMap.totalOrbitCount).to.eql(42);
  });
});
