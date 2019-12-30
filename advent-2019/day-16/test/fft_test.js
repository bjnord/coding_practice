'use strict';
const expect = require('chai').expect;
const fft = require('../src/fft');

/********************
 *  PART ONE TESTS  *
 ********************/

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
describe('multiple phase tests', () => {
  it('should produce the 4th phase correctly [puzzle example #1]', () => {
    const input = '12345678';
    const iList = input.split('').map((i) => Number(i));
    const expected = '01029498';
    const eList = expected.split('').map((e) => Number(e));
    expect(fft.phases(iList, 4).slice(0, 8)).to.eql(eList);
  });
  it('should produce the 100th phase correctly [puzzle example #2]', () => {
    const input = '80871224585914546619083218645595';
    const iList = input.split('').map((i) => Number(i));
    const expected = '24176176';
    const eList = expected.split('').map((e) => Number(e));
    expect(fft.phases(iList, 100).slice(0, 8)).to.eql(eList);
  });
  it('should produce the 100th phase correctly [puzzle example #3]', () => {
    const input = '19617804207202209144916044189917';
    const iList = input.split('').map((i) => Number(i));
    const expected = '73745418';
    const eList = expected.split('').map((e) => Number(e));
    expect(fft.phases(iList, 100).slice(0, 8)).to.eql(eList);
  });
  it('should produce the 100th phase correctly [puzzle example #4]', () => {
    const input = '69317163492948606335995924319873';
    const iList = input.split('').map((i) => Number(i));
    const expected = '52432133';
    const eList = expected.split('').map((e) => Number(e));
    expect(fft.phases(iList, 100).slice(0, 8)).to.eql(eList);
  });
  it('should throw an exception for invalid input (empty element list)', () => {
    const call = () => { fft.phases([], 1); };
    expect(call).to.throw(Error, 'empty element list');
  });
  it('should throw an exception for invalid input (nonpositive phase count)', () => {
    const call = () => { fft.phases([1, 2, 3, 4, 5, 6, 7, 8], 0); };
    expect(call).to.throw(Error, 'invalid phase count');
  });
});

/********************
 *  PART TWO TESTS  *
 ********************/

// see src/experiment.js for background
describe('magical subset behavior tests [8-digit example]', () => {
  let input, eList;
  before(() => {
    input = '80871224';
    const expected = '30871224';
    eList = expected.split('').map((e) => Number(e));
  });
  it('should produce same 100th phase ending [2 repetitions]', () => {
    const input2 = input.repeat(2);
    const iList = input2.split('').map((i) => Number(i));
    expect(fft.phases(iList, 100).slice(-8)).to.eql(eList);
  });
  it('should produce same 100th phase ending [9 repetitions]', () => {
    const input9 = input.repeat(9);
    const iList = input9.split('').map((i) => Number(i));
    expect(fft.phases(iList, 100).slice(-8)).to.eql(eList);
  });
  // [succeeds, but too slow:]
  //it('should produce same 100th phase ending [61 repetitions]', () => {
  //  const input61 = input.repeat(61);
  //  const iList = input61.split('').map((i) => Number(i));
  //  expect(fft.phases(iList, 100).slice(-8)).to.eql(eList);
  //});
});

/*
 * This shows that the "second half" optimization algorithm gives the same
 * result as the full FFT.
 */
const mpriInput = '12345678';
const mpriRepeatCount = 64;
const mpriPhaseCount = 10;
const mpriMessageOffset = 485;
const mpriExpectedOutput = '80242766';
describe('multiple phase w/repeated input tests [Part One brute-force algorithm]', () => {
  let iRepeatedList, oList;
  before(() => {
    iRepeatedList = mpriInput.repeat(mpriRepeatCount).split('').map((i) => Number(i));
    oList = fft.phases(iRepeatedList, mpriPhaseCount);
  });
  it('should find the message correctly', () => {
    const eList = mpriExpectedOutput.split('').map((e) => Number(e));
    expect(oList.length).to.eql(iRepeatedList.length);
    const message = oList.slice(mpriMessageOffset, mpriMessageOffset + 8);
    expect(message).to.eql(eList);
  });
});
describe('multiple phase w/repeated input tests [Part Two Arkoniak algorithm]', () => {
  let iList, message;
  before(() => {
    iList = mpriInput.split('').map((i) => Number(i));
    message = fft.messageFromPhases(iList, mpriRepeatCount, mpriPhaseCount, mpriMessageOffset);
  });
  it('should find the message correctly', () => {
    const eList = mpriExpectedOutput.split('').map((e) => Number(e));
    expect(message).to.eql(eList);
  });
});

/*
 * Part Two puzzle examples
 */
const puzzRepeatCount = 10000;
const puzzPhaseCount = 100;
describe('multiple phase w/repeated input tests [Part Two example #1]', () => {
  let iList, message;
  before(() => {
    const puzzInput = '03036732577212944063491565474664';
    const puzzMessageOffset = Number(puzzInput.slice(0, 7));
    iList = puzzInput.split('').map((i) => Number(i));
    message = fft.messageFromPhases(iList, puzzRepeatCount, puzzPhaseCount, puzzMessageOffset);
  });
  it('should find the message correctly [puzzle example #1]', () => {
    const puzzExpectedOutput = '84462026';
    const eList = puzzExpectedOutput.split('').map((e) => Number(e));
    expect(message).to.eql(eList);
  });
});
describe('multiple phase w/repeated input tests [Part Two example #2]', () => {
  let iList, message;
  before(() => {
    const puzzInput = '02935109699940807407585447034323';
    const puzzMessageOffset = Number(puzzInput.slice(0, 7));
    iList = puzzInput.split('').map((i) => Number(i));
    message = fft.messageFromPhases(iList, puzzRepeatCount, puzzPhaseCount, puzzMessageOffset);
  });
  it('should find the message correctly [puzzle example #2]', () => {
    const puzzExpectedOutput = '78725270';
    const eList = puzzExpectedOutput.split('').map((e) => Number(e));
    expect(message).to.eql(eList);
  });
});
describe('multiple phase w/repeated input tests [Part Two example #3]', () => {
  let iList, message;
  before(() => {
    const puzzInput = '03081770884921959731165446850517';
    const puzzMessageOffset = Number(puzzInput.slice(0, 7));
    iList = puzzInput.split('').map((i) => Number(i));
    message = fft.messageFromPhases(iList, puzzRepeatCount, puzzPhaseCount, puzzMessageOffset);
  });
  it('should find the message correctly [puzzle example #3]', () => {
    const puzzExpectedOutput = '53553731';
    const eList = puzzExpectedOutput.split('').map((e) => Number(e));
    expect(message).to.eql(eList);
  });
});
