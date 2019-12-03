var expect = require('chai').expect;
var module = require('../src/module');
describe('module mass2fuel tests', function() {
  it('should return 2 for 12', function() {
    var mass = 12;
    var fuel = module.mass2fuel(mass);
    expect(fuel).to.eql(2);
  });
  it('should return 2 for 14', function() {
    var mass = 14;
    var fuel = module.mass2fuel(mass);
    expect(fuel).to.eql(2);
  });
  it('should return 654 for 1969', function() {
    var mass = 1969;
    var fuel = module.mass2fuel(mass);
    expect(fuel).to.eql(654);
  });
  it('should return 33583 for 100756', function() {
    var mass = 100756;
    var fuel = module.mass2fuel(mass);
    expect(fuel).to.eql(33583);
  });
});
