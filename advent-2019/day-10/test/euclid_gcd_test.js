'use strict';
const expect = require('chai').expect;
const euclid = require('../src/euclid');
describe('euclid GCD tests', () => {
  it('should return 1 for [1, 5]', () => {
    expect(euclid.gcd(1, 5)).to.eql(1);
  });
  it('should return 1 for [3, 5]', () => {
    expect(euclid.gcd(3, 5)).to.eql(1);
  });
  it('should return 1 for [11, 97]', () => {
    expect(euclid.gcd(11, 97)).to.eql(1);
  });
  it('should return 2 for [2, 6]', () => {
    expect(euclid.gcd(2, 6)).to.eql(2);
  });
  it('should return 3 for [6, 3]', () => {
    expect(euclid.gcd(6, 3)).to.eql(3);
  });
  it('should return 2 for [2, -6]', () => {
    expect(euclid.gcd(2, -6)).to.eql(2);
  });
  it('should return 3 for [6, -3]', () => {
    expect(euclid.gcd(6, -3)).to.eql(3);
  });
  it('should return 2 for [-2, 6]', () => {
    expect(euclid.gcd(-2, 6)).to.eql(2);
  });
  it('should return 3 for [-6, 3]', () => {
    expect(euclid.gcd(-6, 3)).to.eql(3);
  });
  it('should return 2 for [-2, -6]', () => {
    expect(euclid.gcd(-2, -6)).to.eql(2);
  });
  it('should return 3 for [-6, -3]', () => {
    expect(euclid.gcd(-6, -3)).to.eql(3);
  });
  it('should return 12 for [48, 84]', () => {
    expect(euclid.gcd(48, 84)).to.eql(12);
  });
});
