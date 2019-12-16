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
  it('should produce the 6th pattern correctly', () => {
    const expected = /* 0, */ [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 1, 1, 1];
    expect(fft.pattern(32, 5)).to.eql(expected);
  });
  it('should produce the 8th pattern correctly', () => {
    const expected = /* 0, */ [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0];
    expect(fft.pattern(16, 7)).to.eql(expected);
  });
  it('should produce the 9th pattern correctly', () => {
    const expected = /* 0, */ [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1];
    expect(fft.pattern(32, 8)).to.eql(expected);
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
describe('single phase tests', () => {
  it('should produce the first four phases correctly', () => {
    const sequence = [
      [1, 2, 3, 4, 5, 6, 7, 8],
      [4, 8, 2, 2, 6, 1, 5, 8],
      [3, 4, 0, 4, 0, 4, 3, 8],
      [0, 3, 4, 1, 5, 5, 1, 8],
      [0, 1, 0, 2, 9, 4, 9, 8],
    ];
    for (let i = 0; i < sequence.length-1; i++) {
      expect(fft.phase(sequence[i], i)).to.eql(sequence[i+1]);
    }
  });
  it('should throw an exception for invalid input (empty element list)', () => {
    const call = () => { fft.phase([], 0); };
    expect(call).to.throw(Error, 'empty element list');
  });
  it('should throw an exception for invalid input (negative phase index)', () => {
    const call = () => { fft.phase([1, 2, 3, 4, 5, 6, 7, 8], -1); };
    expect(call).to.throw(Error, 'invalid phase index');
  });
});
