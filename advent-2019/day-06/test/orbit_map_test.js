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
describe('orbit map orbit count tests', () => {
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
describe('orbit map parent distance tests', () => {
  it('should count parent distance in 3-level orbit map correctly', () => {
    const orbitMap = new OrbitMap('A)B\nCOM)A\nA)C');
    expect(orbitMap.parentDistance('B', 'A')).to.eql(1);
    expect(orbitMap.parentDistance('B', 'COM')).to.eql(2);
    expect(orbitMap.parentDistance('B', 'C')).to.be.undefined;
    expect(orbitMap.parentDistance('B', 'X')).to.be.undefined;
    expect(orbitMap.parentDistance('X', 'COM')).to.be.undefined;
  });
  it('should count parent distance in puzzle example orbit map correctly', () => {
    const orbitMap = new OrbitMap('COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN\n');
    expect(orbitMap.parentDistance('YOU', 'D')).to.eql(4);
    expect(orbitMap.parentDistance('SAN', 'D')).to.eql(2);
    expect(orbitMap.parentDistance('YOU', 'SAN')).to.be.undefined;
    expect(orbitMap.parentDistance('YOU', 'B')).to.eql(6);
    expect(orbitMap.parentDistance('H', 'B')).to.eql(2);
  });
});
describe('orbit map transfer count tests', () => {
  it('should count transfers in 3-level orbit map correctly', () => {
    const orbitMap = new OrbitMap('A)B\nCOM)A\nA)C');
    expect(orbitMap.transferCount('B', 'C')).to.eql(2);
    expect(orbitMap.transferCount('B', 'X')).to.be.undefined;
    expect(orbitMap.transferCount('X', 'B')).to.be.undefined;
  });
  it('should count transfers in puzzle example orbit map correctly', () => {
    const orbitMap = new OrbitMap('COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN\n');
    expect(orbitMap.transferCount('K', 'I')).to.eql(4);
    expect(orbitMap.transferCount('K', 'H')).to.eql(7);
  });
});
