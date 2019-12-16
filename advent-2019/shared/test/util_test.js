'use strict';
const expect = require('chai').expect;
const util = require('../src/util');
describe('euclid GCD tests', () => {
  it('should return 1 for [1, 5]', () => {
    expect(util.euclidGCD(1, 5)).to.eql(1);
  });
  it('should return 1 for [3, 5]', () => {
    expect(util.euclidGCD(3, 5)).to.eql(1);
  });
  it('should return 1 for [11, 97]', () => {
    expect(util.euclidGCD(11, 97)).to.eql(1);
  });
  it('should return 2 for [2, 6]', () => {
    expect(util.euclidGCD(2, 6)).to.eql(2);
  });
  it('should return 3 for [6, 3]', () => {
    expect(util.euclidGCD(6, 3)).to.eql(3);
  });
  it('should return 2 for [2, -6]', () => {
    expect(util.euclidGCD(2, -6)).to.eql(2);
  });
  it('should return 3 for [6, -3]', () => {
    expect(util.euclidGCD(6, -3)).to.eql(3);
  });
  it('should return 2 for [-2, 6]', () => {
    expect(util.euclidGCD(-2, 6)).to.eql(2);
  });
  it('should return 3 for [-6, 3]', () => {
    expect(util.euclidGCD(-6, 3)).to.eql(3);
  });
  it('should return 2 for [-2, -6]', () => {
    expect(util.euclidGCD(-2, -6)).to.eql(2);
  });
  it('should return 3 for [-6, -3]', () => {
    expect(util.euclidGCD(-6, -3)).to.eql(3);
  });
  it('should return 12 for [48, 84]', () => {
    expect(util.euclidGCD(48, 84)).to.eql(12);
  });
});
describe('LCM tests', () => {
  it('should return 60 for [12, -20]', () => {
    expect(util.LCM(12, -20)).to.eql(60);
  });
  it('should return 300 for [12, 20, 75]', () => {
    expect(util.LCM(12, util.LCM(20, 75))).to.eql(300);
    expect(util.LCM(20, util.LCM(75, 12))).to.eql(300);
    expect(util.LCM(75, util.LCM(12, 20))).to.eql(300);
  });
});
