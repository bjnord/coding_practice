'use strict';
const expect = require('chai').expect;
const password = require('../src/password');
describe('password match tests', () => {
  it('should throw an exception if argument is missing', () => {
    const call = () => { password.passwordMatches(); };
    expect(call).to.throw(Error, 'Invalid argument');
  });
  it('should match on 111111', () => {
    const pass = '111111';
    expect(password.passwordMatches(pass)).to.be.true;
  });
  it('should not match on 223450 (decreasing digits)', () => {
    const pass = '223450';
    expect(password.passwordMatches(pass)).to.be.false;
  });
  it('should not match on 123789 (no double digit)', () => {
    const pass = '123789';
    expect(password.passwordMatches(pass)).to.be.false;
  });
});
describe('password match(2) tests', () => {
  it('should throw an exception if argument is missing', () => {
    const call = () => { password.passwordMatchesToo(); };
    expect(call).to.throw(Error, 'Invalid argument');
  });
  it('should match on 112233', () => {
    const pass = '112233';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should match on 112345 (lone pair at start)', () => {
    const pass = '112345';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should match on 123455 (lone pair at end)', () => {
    const pass = '123455';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should not match on 123444 (no lone pair)', () => {
    const pass = '123444';
    expect(password.passwordMatchesToo(pass)).to.be.false;
  });
  it('should not match on 111234 (no lone pair)', () => {
    const pass = '111234';
    expect(password.passwordMatchesToo(pass)).to.be.false;
  });
  it('should match on 111122 (does have one lone pair)', () => {
    const pass = '111122';
    expect(password.passwordMatchesToo(pass)).to.be.true;
  });
  it('should not match on 223450 (decreasing digits)', () => {
    const pass = '223450';
    expect(password.passwordMatchesToo(pass)).to.be.false;
  });
});
