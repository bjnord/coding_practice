'use strict';
const expect = require('chai').expect;
const math = require('../src/math');
describe('modulo tests', () => {
  it('should evaluate 5 mod 2 correctly', () => {
    expect(math.mod(5, 2)).to.eql(1);
  });
  it('should evaluate 9 mod 3 correctly', () => {
    expect(math.mod(9, 3)).to.eql(0);
  });
  it('should evaluate -1 mod 3 correctly', () => {
    expect(math.mod(-1, 3)).to.eql(2);
  });
});
