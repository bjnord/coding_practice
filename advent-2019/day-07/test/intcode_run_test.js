'use strict';
const expect = require('chai').expect;
const intcode = require('../src/intcode');
const tryAmp = (program, settings) => {
  const values = [0];
  for (const setting of settings) {
    // "Make sure that memory is not shared or reused between copies of the program."
    const programCopy = program.slice();
    // inputs: FIRST the amp phase setting, SECOND the input value
    values.unshift(setting);
    intcode.run(programCopy, false, values);
  }
  return values[0];
};
describe('intcode run tests', () => {
  it('should return 43210 from example program 1 with settings 4,3,2,1,0', () => {
    const program = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0];
    const settings = [4,3,2,1,0];
    expect(tryAmp(program, settings)).to.eql(43210);
  });
  it('should return 54321 from example program 1 with settings 0,1,2,3,4', () => {
    const program = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0];
    const settings = [0,1,2,3,4];
    expect(tryAmp(program, settings)).to.eql(54321);
  });
  it('should return 65210 from example program 1 with settings 1,0,4,3,2', () => {
    const program = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0];
    const settings = [1,0,4,3,2];
    expect(tryAmp(program, settings)).to.eql(65210);
  });
});
