'use strict';
const expect = require('chai').expect;
const intcode = require('../src/intcode');
describe('intcode run tests', () => {
  // position (indirect) mode tests:
  it('should transform 1,0,0,0,99 to 2,0,0,0,99', () => {
    const program = [1,0,0,0,99];
    expect(intcode.run(program)).to.eql([2,0,0,0,99]);
  });
  it('should transform 2,3,0,3,99 to 2,3,0,6,99', () => {
    const program = [2,3,0,3,99];
    expect(intcode.run(program)).to.eql([2,3,0,6,99]);
  });
  it('should transform 2,4,4,5,99,0 to 2,4,4,5,99,9801', () => {
    const program = [2,4,4,5,99,0];
    expect(intcode.run(program)).to.eql([2,4,4,5,99,9801]);
  });
  it('should transform 1,1,1,4,99,5,6,0,99 to 30,1,1,4,2,5,6,0,99', () => {
    const program = [1,1,1,4,99,5,6,0,99];
    expect(intcode.run(program)).to.eql([30,1,1,4,2,5,6,0,99]);
  });
  // immediate mode tests:
  it('should transform 1002,4,3,4,33 to 1002,4,3,4,99', () => {
    const program = [1002,4,3,4,33];
    expect(intcode.run(program)).to.eql([1002,4,3,4,99]);
  });
  it('should transform 102,3,4,4,33 to 102,3,4,4,99', () => {
    const program = [102,3,4,4,33];
    expect(intcode.run(program)).to.eql([102,3,4,4,99]);
  });
  it('should transform 1101,54,45,4,0 to 1101,54,45,4,99', () => {
    const program = [1101,54,45,4,0];
    expect(intcode.run(program)).to.eql([1101,54,45,4,99]);
  });
  it('should throw an exception for invalid opcode', () => {
    const program = [98,0,0,5,99,0];
    const call = () => { intcode.run(program); };
    expect(call).to.throw(Error, 'invalid opcode 98 at PC=0');
  });
  // I/O tests (not normally enabled, e.g. IN can't be automated):
  //it('should transform 3,3,99,0 to 3,3,99,1', () => {
  //  const program = [3,3,99,0];
  //  expect(intcode.run(program)).to.eql([3,3,99,1]);
  //});
  //it('should not change 4,2,99', () => {
  //  const program = [4,2,99];
  //  expect(intcode.run(program)).to.eql(program);
  //});
  //it('should not change 104,7,99', () => {
  //  const program = [104,7,99];
  //  expect(intcode.run(program)).to.eql(program);
  //});
});
