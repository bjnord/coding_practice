'use strict';
const expect = require('chai').expect;
const rocket = require('../src/rocket');
describe('mass2fuel tests', () => {
  it('should return 2 for 12', () => {
    const mass = 12;
    expect(rocket.mass2fuel(mass)).to.eql(2);
  });
  it('should return 2 for 14', () => {
    const mass = 14;
    expect(rocket.mass2fuel(mass)).to.eql(2);
  });
  it('should return 654 for 1969', () => {
    const mass = 1969;
    expect(rocket.mass2fuel(mass)).to.eql(654);
  });
  it('should return 33583 for 100756', () => {
    const mass = 100756;
    expect(rocket.mass2fuel(mass)).to.eql(33583);
  });
});
