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
describe('password match(2) tests', function() {
  it('should throw an exception if argument is missing', function () {
    const call = function () { password.passwordMatchesToo(); };
    expect(call).to.throw(Error, 'Invalid argument');
   });
  it('should match on 112233', function () {
    const pass = '112233';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should match on 112345 (lone pair at start)', function () {
    const pass = '112345';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should match on 123455 (lone pair at end)', function () {
    const pass = '123455';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should not match on 123444 (no lone pair)', function () {
    const pass = '123444';
    expect(password.passwordMatchesToo(pass)).to.be.false;
  });
  it('should not match on 111234 (no lone pair)', function () {
    const pass = '111234';
    expect(password.passwordMatchesToo(pass)).to.be.false;
  });
  it('should match on 111122 (does have one lone pair)', function () {
    const pass = '111122';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should not match on 223450 (decreasing digits)', function () {
    const pass = '223450';
    expect(password.passwordMatchesToo(pass)).to.be.false;
  });
});
