'use strict';
const expect = require('chai').expect;
const rocket = require('../src/rocket');
describe('mass2fullfuel tests', () => {
  it('should return 2 for 14', () => {
    const mass = 14;
    expect(rocket.mass2fullfuel(mass)).to.eql(2);
  });
  it('should return 966 for 1969', () => {
    const mass = 1969;
    expect(rocket.mass2fullfuel(mass)).to.eql(966);
  });
  it('should return 50346 for 100756', () => {
    const mass = 100756;
    expect(rocket.mass2fullfuel(mass)).to.eql(50346);
  });
});
