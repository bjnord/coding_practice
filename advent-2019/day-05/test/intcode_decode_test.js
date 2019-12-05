'use strict';
const expect = require('chai').expect;
const intcode = require('../src/intcode');
describe('intcode decode tests', () => {
  it('should decode 1,0,0,0 to {1,3,[0,0,0],[0,0,0]}', () => {
    const program = [1,0,0,0,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 1,
      argCount: 3,
      modes: [0, 0, 0],
      args: [0, 0, 0],
    });
  });
  it('should decode 101,-1,2,3 to {1,3,[1,0,0],[-1,2,3]}', () => {
    const program = [101,-1,2,3];
    expect(intcode.decode(program)).to.eql({
      opcode: 1,
      argCount: 3,
      modes: [1, 0, 0],
      args: [-1, 2, 3],
    });
  });
  it('should decode 1101,612,763,651 to {1,3,[1,1,0],[612,763,651]}', () => {
    const program = [1101,612,763,651,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 1,
      argCount: 3,
      modes: [1, 1, 0],
      args: [612, 763, 651],
    });
  });
  it('should decode 2,3,1,5 to {2,3,[0,0,0],[3,1,5]}', () => {
    const program = [2,3,1,5];
    expect(intcode.decode(program)).to.eql({
      opcode: 2,
      argCount: 3,
      modes: [0, 0, 0],
      args: [3, 1, 5],
    });
  });
  it('should decode 1002,4,3,4 to {2,3,[0,1,0],[4,3,4]}', () => {
    const program = [1002,4,3,4,33];
    expect(intcode.decode(program)).to.eql({
      opcode: 2,
      argCount: 3,
      modes: [0, 1, 0],
      args: [4, 3, 4],
    });
  });
  it('should decode 3,50 to {3,1,[0],[50]}', () => {
    const program = [3,50,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 3,
      argCount: 1,
      modes: [0],
      args: [50],
    });
  });
  it('should decode 4,50 to {4,1,[0],[50]}', () => {
    const program = [4,50];
    expect(intcode.decode(program)).to.eql({
      opcode: 4,
      argCount: 1,
      modes: [0],
      args: [50],
    });
  });
  it('should decode 104,55 to {4,1,[1],[55]}', () => {
    const program = [104,55,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 4,
      argCount: 1,
      modes: [1],
      args: [55],
    });
  });
  it('should decode 99 to {99,0,[],[]}', () => {
    const program = [99,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 99,
      argCount: 0,
      modes: [],
      args: [],
    });
  });
});
describe('intcode instructionString tests', () => {
  it('should render 1001,1,2,3 as "ADD M1,2,M3"', () => {
    const program = [1001,1,2,3];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('ADD M1,2,M3');
  });
  it('should render 102,3,1,5 as "MUL 3,M1,M5"', () => {
    const program = [102,3,1,5];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('MUL 3,M1,M5');
  });
  it('should render 4.50 as "OUT M50"', () => {
    const program = [4,50];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('OUT M50');
  });
});
