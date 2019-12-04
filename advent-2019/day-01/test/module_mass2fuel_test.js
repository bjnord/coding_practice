'use strict';
const expect = require('chai').expect;
const spaceModule = require('../src/module');
describe('module mass2fuel tests', function () {
  it('should return 2 for 12', function () {
    const mass = 12;
    expect(spaceModule.mass2fuel(mass)).to.eql(2);
  });
  it('should return 2 for 14', function () {
    const mass = 14;
    expect(spaceModule.mass2fuel(mass)).to.eql(2);
  });
  it('should return 654 for 1969', function () {
    const mass = 1969;
    expect(spaceModule.mass2fuel(mass)).to.eql(654);
  });
  it('should return 33583 for 100756', function () {
    const mass = 100756;
    expect(spaceModule.mass2fuel(mass)).to.eql(33583);
  });
});
