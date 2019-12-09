'use strict';
const expect = require('chai').expect;
const intcode = require('../src/intcode');
describe('intcode run tests', () => {
  // TODO add tests for invalid/missing iState.pc and .rb values
  //      passed into run()
  // TODO add tests for illegal memory access: both relative mode
  //      (operand + RB < 0) and position mode (operand < 0)
  // position (indirect) mode tests:
  it('should transform 1,0,0,0,99 to 2,0,0,0,99', () => {
    const program = [1,0,0,0,99];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([2,0,0,0,99]);
  });
  it('should transform 2,3,0,3,99 to 2,3,0,6,99', () => {
    const program = [2,3,0,3,99];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([2,3,0,6,99]);
  });
  it('should transform 2,4,4,5,99,0 to 2,4,4,5,99,9801', () => {
    const program = [2,4,4,5,99,0];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([2,4,4,5,99,9801]);
  });
  it('should transform 1,1,1,4,99,5,6,0,99 to 30,1,1,4,2,5,6,0,99', () => {
    const program = [1,1,1,4,99,5,6,0,99];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([30,1,1,4,2,5,6,0,99]);
  });
  it('should transform 8,5,6,7,99,8,8,-1 to 8,5,6,7,99,8,8,1', () => {
    const program = [8,5,6,7,99,8,8,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([8,5,6,7,99,8,8,1]);
  });
  it('should transform 8,5,6,7,99,7,8,-1 to 8,5,6,7,99,7,8,0', () => {
    const program = [8,5,6,7,99,7,8,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([8,5,6,7,99,7,8,0]);
  });
  it('should transform 7,5,6,7,99,8,8,-1 to 7,5,6,7,99,8,8,0', () => {
    const program = [7,5,6,7,99,8,8,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([7,5,6,7,99,8,8,0]);
  });
  it('should transform 7,5,6,7,99,7,8,-1 to 7,5,6,7,99,7,8,1', () => {
    const program = [7,5,6,7,99,7,8,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([7,5,6,7,99,7,8,1]);
  });
  it('should leave 6,8,11,1,9,10,9,99,0,0,1,7 untransformed', () => {
    const program = [6,8,11,1,9,10,9,99,0,0,1,7];
    const programCopy = program.slice();
    expect(intcode.run(programCopy).state).to.eql('halt');
    expect(programCopy).to.eql(program);
  });
  it('should transform 6,8,11,1,9,10,9,99,55,0,1,7 to 6,8,11,1,9,10,9,99,55,1,1,7', () => {
    const program = [6,8,11,1,9,10,9,99,55,0,1,7];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([6,8,11,1,9,10,9,99,55,1,1,7]);
  });
  // immediate mode tests:
  it('should transform 1002,4,3,4,33 to 1002,4,3,4,99', () => {
    const program = [1002,4,3,4,33];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1002,4,3,4,99]);
  });
  it('should transform 102,3,4,4,33 to 102,3,4,4,99', () => {
    const program = [102,3,4,4,33];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([102,3,4,4,99]);
  });
  it('should transform 1101,54,45,4,0 to 1101,54,45,4,99', () => {
    const program = [1101,54,45,4,0];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1101,54,45,4,99]);
  });
  it('should throw an exception for invalid opcode', () => {
    const program = [98,0,0,5,99,0];
    const call = () => { intcode.run(program); };
    expect(call).to.throw(Error, 'invalid opcode 98 at PC=0');
  });
  it('should transform 1108,8,8,5,99,-1 to 1108,8,8,5,99,1', () => {
    const program = [1108,8,8,5,99,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1108,8,8,5,99,1]);
  });
  it('should transform 1108,7,8,5,99,-1 to 1108,7,8,5,99,0', () => {
    const program = [1108,7,8,5,99,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1108,7,8,5,99,0]);
  });
  it('should transform 1107,8,8,5,99,-1 to 1107,8,8,5,99,0', () => {
    const program = [1107,8,8,5,99,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1107,8,8,5,99,0]);
  });
  it('should transform 1107,7,8,5,99,-1 to 1107,7,8,5,99,1', () => {
    const program = [1107,7,8,5,99,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1107,7,8,5,99,1]);
  });
  it('should leave 1105,1,7,1101,0,0,8,99,1 untransformed', () => {
    const program = [1105,1,7,1101,0,0,8,99,1];
    const programCopy = program.slice();
    expect(intcode.run(programCopy).state).to.eql('halt');
    expect(programCopy).to.eql(program);
  });
  it('should transform 1105,0,7,1101,0,0,8,99,1 to 1105,0,7,1101,0,0,8,99,0', () => {
    const program = [1105,0,7,1101,0,0,8,99,1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1105,0,7,1101,0,0,8,99,0]);
  });
  // relative mode tests:
  it('should transform 109,1,2101,0,7,9,99,7,77,-1 to 109,1,2101,0,7,9,99,7,77,77', () => {
    const program = [109,1,2101,0,7,9,99,7,77,-1];  // relative +operand, +RB
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([109,1,2101,0,7,9,99,7,77,77]);
  });
  it('should transform 109,9,2101,0,-1,9,99,6,66,-1 to 109,9,2101,0,-1,9,99,6,66,66', () => {
    const program = [109,9,2101,0,-1,9,99,6,66,-1];  // relative -operand, +RB
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([109,9,2101,0,-1,9,99,6,66,66]);
  });
  it('should transform 109,-2,2101,0,10,9,99,5,55,-1 to 109,-2,2101,0,10,9,99,5,55,55', () => {
    const program = [109,-2,2101,0,10,9,99,5,55,-1];  // relative +operand, -RB
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([109,-2,2101,0,10,9,99,5,55,55]);
  });
  it('should transform 109,-1,21102,2,3,8,99,-1,-1 to 109,-1,21102,2,3,8,99,6,-1', () => {
    const program = [109,-1,21102,2,3,8,99,-1,-1];  // relative store, -RB
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([109,-1,21102,2,3,8,99,6,-1]);
  });
  // ARB tests:
  it('should return RB adjusted +15 (immediate mode)', () => {
    const program = [109,15,99];
    const iState = intcode.run(...[program, , , , {pc: 0, rb: 7}]);
    expect(iState.state).to.eql('halt');
    expect(iState.rb).to.eql(22);
  });
  it('should return RB adjusted -12 (position mode)', () => {
    const program = [9,3,99,-12];
    const iState = intcode.run(...[program, , , , {pc: 0, rb: 33}]);
    expect(iState.state).to.eql('halt');
    expect(iState.rb).to.eql(21);
  });
  // I/O tests, headless mode:
  it('should return n * 2 + 1 from headless mode', () => {
    const program = [3,13,1002,13,2,13,1001,13,1,13,4,13,99,-1];
    const values = [3];
    const popValue = () => values.shift();
    const pushValue = (v) => values.unshift(v);
    expect(intcode.run(program, false, popValue, pushValue).state).to.eql('halt');
    expect(values[0]).to.eql(7);
  });
  it('should support pause in headless mode when no input is available', () => {
    const program = [3,11,3,12,1,11,12,13,4,13,99,-1,-2,-3];
    const values = [303];
    const popValue = () => values.shift();
    const pushValue = (v) => values.unshift(v);
    // step 1 (pauses at 2nd IN)
    let iState = intcode.run(program, false, popValue, pushValue);
    expect(iState.pc).to.eql(2);
    expect(iState.state).to.eql('iowait');
    expect(program[11]).to.eql(303);
    expect(program[12]).to.eql(-2);
    expect(program[13]).to.eql(-3);
    // step 2 (halts)
    values.unshift(10);
    iState = intcode.run(program, false, popValue, pushValue, iState);
    expect(iState.state).to.eql('halt');
    expect(program[11]).to.eql(303);
    expect(program[12]).to.eql(10);
    expect(program[13]).to.eql(313);
    expect(values[0]).to.eql(313);
  });
  // Infinite memory tests:
  it('should get 0 for locations beyond end of program (position mode)', () => {
    const program = [101,3,10,5,99,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([101,3,10,5,99,3]);
  });
  it('should get 0 for locations beyond end of program (relative mode)', () => {
    const program = [2102,6,11,5,99,-1];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([2102,6,11,5,99,0]);
  });
  it('should be able to store values at locations beyond end of program', () => {
    const program = [1101,3,5,15,1101,2,3,14,1101,1,2,13,99];
    expect(intcode.run(program).state).to.eql('halt');
    expect(program).to.eql([1101,3,5,15,1101,2,3,14,1101,1,2,13,99,3,5,8]);
  });
  it('should produce a copy of itself as output (day 9 example #1)', () => {
    const program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99];
    const values = [];
    const storeValue = (v) => values.push(v);
    expect(intcode.run(program, false, undefined, storeValue).state).to.eql('halt');
    expect(values).to.eql([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]);
  });
});
