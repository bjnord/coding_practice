var expect = require('chai').expect;
var module = require('../src/module');
describe('module mass2fuel tests', function() {
  it('should return 2 for 12', function() {
    const mass = 12;
    expect(module.mass2fuel(mass)).to.eql(2);
  });
  it('should return 2 for 14', function() {
    const mass = 14;
    expect(module.mass2fuel(mass)).to.eql(2);
  });
  it('should return 654 for 1969', function() {
    const mass = 1969;
    expect(module.mass2fuel(mass)).to.eql(654);
  });
  it('should return 33583 for 100756', function() {
    const mass = 100756;
    expect(module.mass2fuel(mass)).to.eql(33583);
  });
});
