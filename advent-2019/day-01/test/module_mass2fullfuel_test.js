'use strict';
const expect = require('chai').expect;
const spaceModule = require('../src/module');
describe('module mass2fullfuel tests', function () {
  it('should return 2 for 14', function () {
    const mass = 14;
    expect(spaceModule.mass2fullfuel(mass)).to.eql(2);
  });
  it('should return 966 for 1969', function () {
    const mass = 1969;
    expect(spaceModule.mass2fullfuel(mass)).to.eql(966);
  });
  it('should return 50346 for 100756', function () {
    const mass = 100756;
    expect(spaceModule.mass2fullfuel(mass)).to.eql(50346);
  });
});
