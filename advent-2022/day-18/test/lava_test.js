'use strict';
const expect = require('chai').expect;
const lava = require('../src/lava');
const exampleInput = '1,1,1\n2,1,1\n';
const exampleInput2 = '2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n1,2,5\n3,2,5\n2,1,5\n2,3,5\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(lava.parseLine('2,1,5')).to.eql({z: 5, y: 1, x: 2});
  });
  it('should parse a whole input set correctly', () => {
    const expected2 = [
      {z: 2, y: 2, x: 2},
      {z: 2, y: 2, x: 1},
      {z: 2, y: 2, x: 3},
      {z: 2, y: 1, x: 2},
      {z: 2, y: 3, x: 2},
      {z: 1, y: 2, x: 2},
      {z: 3, y: 2, x: 2},
      {z: 4, y: 2, x: 2},
      {z: 6, y: 2, x: 2},
      {z: 5, y: 2, x: 1},
      {z: 5, y: 2, x: 3},
      {z: 5, y: 1, x: 2},
      {z: 5, y: 3, x: 2},
    ];
    expect(lava.parse(exampleInput2)).to.eql(expected2);
  });
});
describe('surface area tests', () => {
  it('should calculate the first example correctly', () => {
    const droplet = lava.parse(exampleInput);
    expect(lava.surfaceArea(droplet)).to.equal(10);
  });
  it('should calculate the second example correctly', () => {
    const droplet = lava.parse(exampleInput2);
    expect(lava.surfaceArea(droplet)).to.equal(64);
  });
  it('should calculate the second example correctly (true)', () => {
    const droplet = lava.parse(exampleInput2);
    expect(lava.trueSurfaceArea(droplet)).to.equal(58);
  });
});
