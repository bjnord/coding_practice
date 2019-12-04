'use strict';
const expect = require('chai').expect;
const intcode = require('../src/intcode');
describe('intcode run tests', () => {
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
  it('should throw an exception for invalid opcode', () => {
    const program = [3,0,0,5,99,0];
    const call = () => { intcode.run(program); };
    expect(call).to.throw(Error, 'invalid opcode 3 at PC=0');
  });
});
