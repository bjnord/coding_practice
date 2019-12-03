var expect = require('chai').expect;
var Module = require('../src/module');
describe('module mass2fullfuel tests', function() {
  var module;
  beforeEach(function() {
    module = new Module();
  });
  it('should return 2 for 14', function() {
    var mass = 14;
    var fuel = module.mass2fullfuel(mass);
    expect(fuel).to.eql(2);
  });
  it('should return 966 for 1969', function() {
    var mass = 1969;
    var fuel = module.mass2fullfuel(mass);
    expect(fuel).to.eql(966);
  });
  it('should return 50346 for 100756', function() {
    var mass = 100756;
    var fuel = module.mass2fullfuel(mass);
    expect(fuel).to.eql(50346);
  });
});
