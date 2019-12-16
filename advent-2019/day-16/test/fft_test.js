'use strict';
const expect = require('chai').expect;
const fft = require('../src/fft');
describe('pattern tests', () => {
  it('should produce the 1st pattern correctly', () => {
    const expected = /* 0, */ [1, 0, -1, 0, 1, 0, -1, 0, 1, 0, -1, 0, 1, 0, -1, 0];
    expect(fft.pattern(16, 0)).to.eql(expected);
  });
  it('should produce the 2nd pattern correctly', () => {
    const expected = /* 0, */ [0, 1, 1, 0, 0, -1, -1, 0, 0, 1, 1, 0, 0, -1, -1, 0];
    expect(fft.pattern(16, 1)).to.eql(expected);
  });
  it('should produce the 4th pattern correctly', () => {
    const expected = /* 0, */ [0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, -1, -1, -1, -1, 0];
    expect(fft.pattern(16, 3)).to.eql(expected);
  });
  it('should produce the 5th pattern correctly', () => {
    const expected = /* 0, */ [0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, -1, -1];
    expect(fft.pattern(16, 4)).to.eql(expected);
  });
  it('should produce the 8th pattern correctly', () => {
    const expected = /* 0, */ [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0];
    expect(fft.pattern(16, 7)).to.eql(expected);
  });
  it('should throw an exception for invalid input (non-positive element count)', () => {
    const call = () => { fft.pattern(0, 2); };
    expect(call).to.throw(Error, 'invalid element count');
  });
  it('should throw an exception for invalid input (negative pattern index)', () => {
    const call = () => { fft.pattern(8, -1); };
    expect(call).to.throw(Error, 'invalid pattern index');
  });
});
