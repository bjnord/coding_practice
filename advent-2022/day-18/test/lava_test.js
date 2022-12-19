'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const lava = require('../src/lava');
const exampleInput = '1,1,1\n2,1,1\n';
const exampleInput2 = '2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n1,2,5\n3,2,5\n2,1,5\n2,3,5\n';
const exampleInputCatbert = fs.readFileSync('input/Catbert321.txt', 'utf8');
/*
 * a 5x4x6 box that has:
 * - an exterior tunnel opening cube at z=1
 * - a 2x4 interior cavern at z=2 (reachable via tunnel opening)
 * - a 2x4 interior cavern at z=4 (sealed, not reachable)
 * - 5*4*6 total cubes - 1 - 8 - 8 = 103 lava cubes
 */
const exampleInputTunnel = fs.readFileSync('input/tunnel.txt', 'utf8');
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(lava.parseLine('2,1,5')).to.eql({z: 5, y: 1, x: 2, s: '2,1,5'});
  });
  it('should parse a whole input set correctly', () => {
    const expected2 = [
      {z: 2, y: 2, x: 2, s: '2,2,2'},
      {z: 2, y: 2, x: 1, s: '1,2,2'},
      {z: 2, y: 2, x: 3, s: '3,2,2'},
      {z: 2, y: 1, x: 2, s: '2,1,2'},
      {z: 2, y: 3, x: 2, s: '2,3,2'},
      {z: 1, y: 2, x: 2, s: '2,2,1'},
      {z: 3, y: 2, x: 2, s: '2,2,3'},
      {z: 4, y: 2, x: 2, s: '2,2,4'},
      {z: 6, y: 2, x: 2, s: '2,2,6'},
      {z: 5, y: 2, x: 1, s: '1,2,5'},
      {z: 5, y: 2, x: 3, s: '3,2,5'},
      {z: 5, y: 1, x: 2, s: '2,1,5'},
      {z: 5, y: 3, x: 2, s: '2,3,5'},
    ];
    expect(lava.parse(exampleInput2)).to.eql(expected2);
  });
});
describe('simple surface area tests', () => {
  it('should calculate simple surface area correctly (1st example)', () => {
    const droplet = lava.parse(exampleInput);
    expect(lava.simpleSurfaceArea(droplet)).to.equal(10);
  });
  it('should calculate simple surface area correctly (2nd example)', () => {
    const droplet2 = lava.parse(exampleInput2);
    expect(lava.simpleSurfaceArea(droplet2)).to.equal(64);
  });
  it('should calculate simple surface area correctly (Catbert321 example)', () => {
    const dropletCatbert = lava.parse(exampleInputCatbert);
    expect(lava.simpleSurfaceArea(dropletCatbert)).to.equal(108);
  });
});
describe('true surface area tests', () => {
  it('should calculate dimensions correctly (1st example)', () => {
    const droplet = lava.parse(exampleInput);
    const expected = {
      minZ: 1, maxZ: 1,
      minY: 1, maxY: 1,
      minX: 1, maxX: 2,
    };
    expect(lava.dropletDim(droplet)).to.eql(expected);
  });
  it('should calculate dimensions correctly (tunnel example)', () => {
    const dropletTunnel = lava.parse(exampleInputTunnel);
    const expected = {
      minZ: 1, maxZ: 5,
      minY: 1, maxY: 4,
      minX: 1, maxX: 6,
    };
    expect(lava.dropletDim(dropletTunnel)).to.eql(expected);
  });
  it('should calculate dimensions correctly (2nd example)', () => {
    const droplet2 = lava.parse(exampleInput2);
    const expected = {
      minZ: 1, maxZ: 6,
      minY: 1, maxY: 3,
      minX: 1, maxX: 3,
    };
    expect(lava.dropletDim(droplet2)).to.eql(expected);
  });
  it('should calculate surface area correctly (1st example)', () => {
    const droplet = lava.parse(exampleInput);
    expect(lava.trueSurfaceArea(droplet)).to.equal(10);
  });
  it('should calculate surface area correctly (2nd example)', () => {
    const droplet2 = lava.parse(exampleInput2);
    expect(lava.trueSurfaceArea(droplet2)).to.equal(58);
  });
  it('should calculate surface area correctly (Catbert321 example)', () => {
    const dropletCatbert = lava.parse(exampleInputCatbert);
    expect(lava.trueSurfaceArea(dropletCatbert)).to.equal(90);
  });
  it('should calculate surface area correctly (tunnel example)', () => {
    // see comment at top for description of this object
    const dropletTunnel = lava.parse(exampleInputTunnel);
    expect(dropletTunnel.length).to.equal(103);
    const boxSurface = 2 * (5 * 4) + 2 * (5 * 6) + 2 * (4 * 6);
    const expSurface = boxSurface
      - 1                // tunnel opening cube exterior hole
      + 4                // tunnel opening cube faces
      + 2 * (2 * 4) - 1  // tunnel chamber front/back faces (- hole)
      + 2 * (1 * 4)      // tunnel chamber top/bottom faces
      + 2 * (1 * 2);     // tunnel chamber left/right faces
    expect(lava.trueSurfaceArea(dropletTunnel)).to.equal(expSurface);
  });
});
