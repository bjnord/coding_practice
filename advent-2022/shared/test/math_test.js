'use strict';
const expect = require('chai').expect;
const math = require('../src/math');
describe('modulo tests', () => {
  it('should evaluate 5 mod 2 correctly', () => {
    expect(math.mod(5, 2)).to.eql(1);
  });
  it('should evaluate 9 mod 3 correctly', () => {
    expect(math.mod(9, 3)).to.eql(0);
  });
  it('should evaluate -1 mod 3 correctly', () => {
    expect(math.mod(-1, 3)).to.eql(2);
  });
});
describe('integer-unit tests', () => {
  it('should evaluate zero correctly', () => {
    expect(math.intUnit(0)).to.equal(0);
  });
  it('should evaluate negatives correctly', () => {
    expect(math.intUnit(-1)).to.equal(-1);
    expect(math.intUnit(-3)).to.equal(-1);
    expect(math.intUnit(-10)).to.equal(-1);
  });
  it('should evaluate positives correctly', () => {
    expect(math.intUnit(1)).to.equal(1);
    expect(math.intUnit(3)).to.equal(1);
    expect(math.intUnit(10)).to.equal(1);
  });
});
describe('chessboard distance tests', () => {
  it('should compute chessboard distance correctly', () => {
    const positions = [
      [{y: 0, x: 0}, {y: 0, x: 0}, 0],
      [{y: 1, x: 1}, {y: 2, x: 1}, 1],
      [{y: -1, x: -1}, {y: -2, x: -1}, 1],
      [{y: 0, x: 2}, {y: 1, x: 3}, 1],
      [{y: 0, x: -2}, {y: -1, x: -3}, 1],
      [{y: 3, x: -1}, {y: 4, x: 1}, 2],
      [{y: -2, x: 1}, {y: -4, x: 2}, 2],
    ];
    for (let i = 0; i < positions.length; i++) {
      expect(math.chessboardDistance(positions[i][0], positions[i][1])).to.equal(positions[i][2]);
      expect(math.chessboardDistance(positions[i][1], positions[i][0])).to.equal(positions[i][2]);
    }
  });
});
