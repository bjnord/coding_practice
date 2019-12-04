var expect = require('chai').expect;
var password = require('../src/password');
describe('password match tests', function() {
  it('should throw an exception if argument is missing', function () {
    const call = function () { password.passwordMatches(); };
    expect(call).to.throw(Error, 'Invalid argument');
   });
  it('should match on 111111', function () {
    const pass = '111111';
    expect(password.passwordMatches(pass)).to.be.true;
  });
  it('should not match on 223450 (decreasing digits)', function () {
    const pass = '223450';
    expect(password.passwordMatches(pass)).to.be.false;
  });
  it('should not match on 123789 (no double digit)', function () {
    const pass = '123789';
    expect(password.passwordMatches(pass)).to.be.false;
  });
});
