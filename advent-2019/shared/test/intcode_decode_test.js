'use strict';
const expect = require('chai').expect;
const intcode = require('../src/intcode');
describe('intcode decode tests', () => {
  it('should decode 1,0,0,0 to {1,ADD,3,[0,0,0],[0,0,0]}', () => {
    const program = [1,0,0,0,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 1,
      opcodeName: 'ADD',
      argCount: 3,
      storeArgIndex: 2,
      modes: [0, 0, 0],
      args: [0, 0, 0],
    });
  });
  it('should decode 101,-1,2,3 to {1,ADD,3,[1,0,0],[-1,2,3]}', () => {
    const program = [101,-1,2,3];
    expect(intcode.decode(program)).to.eql({
      opcode: 1,
      opcodeName: 'ADD',
      argCount: 3,
      storeArgIndex: 2,
      modes: [1, 0, 0],
      args: [-1, 2, 3],
    });
  });
  it('should decode 2101,-1,2,3 to {1,ADD,3,[1,2,0],[-1,2,3]}', () => {
    const program = [2101,-1,2,3];
    expect(intcode.decode(program)).to.eql({
      opcode: 1,
      opcodeName: 'ADD',
      argCount: 3,
      storeArgIndex: 2,
      modes: [1, 2, 0],
      args: [-1, 2, 3],
    });
  });
  it('should decode 1101,612,763,651 to {1,ADD,3,[1,1,0],[612,763,651]}', () => {
    const program = [1101,612,763,651,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 1,
      opcodeName: 'ADD',
      argCount: 3,
      storeArgIndex: 2,
      modes: [1, 1, 0],
      args: [612, 763, 651],
    });
  });
  it('should decode 2,3,1,5 to {2,MUL,3,[0,0,0],[3,1,5]}', () => {
    const program = [2,3,1,5];
    expect(intcode.decode(program)).to.eql({
      opcode: 2,
      opcodeName: 'MUL',
      argCount: 3,
      storeArgIndex: 2,
      modes: [0, 0, 0],
      args: [3, 1, 5],
    });
  });
  it('should decode 1002,4,3,4 to {2,MUL,3,[0,1,0],[4,3,4]}', () => {
    const program = [1002,4,3,4,33];
    expect(intcode.decode(program)).to.eql({
      opcode: 2,
      opcodeName: 'MUL',
      argCount: 3,
      storeArgIndex: 2,
      modes: [0, 1, 0],
      args: [4, 3, 4],
    });
  });
  it('should decode 1202,4,3,4 to {2,MUL,3,[2,1,0],[4,3,4]}', () => {
    const program = [1202,4,3,4,33];
    expect(intcode.decode(program)).to.eql({
      opcode: 2,
      opcodeName: 'MUL',
      argCount: 3,
      storeArgIndex: 2,
      modes: [2, 1, 0],
      args: [4, 3, 4],
    });
  });
  it('should decode 3,50 to {3,IN,1,[0],[50]}', () => {
    const program = [3,50,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 3,
      opcodeName: 'IN',
      argCount: 1,
      storeArgIndex: 0,
      modes: [0],
      args: [50],
    });
  });
  it('should decode 4,50 to {4,OUT,1,[0],[50]}', () => {
    const program = [4,50];
    expect(intcode.decode(program)).to.eql({
      opcode: 4,
      opcodeName: 'OUT',
      argCount: 1,
      storeArgIndex: null,
      modes: [0],
      args: [50],
    });
  });
  it('should decode 104,55 to {4,OUT,1,[1],[55]}', () => {
    const program = [104,55,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 4,
      opcodeName: 'OUT',
      argCount: 1,
      storeArgIndex: null,
      modes: [1],
      args: [55],
    });
  });
  it('should decode 5,1,3 to {5,JTRU,2,[0,0],[1,3]}', () => {
    const program = [5,1,3];
    expect(intcode.decode(program)).to.eql({
      opcode: 5,
      opcodeName: 'JTRU',
      argCount: 2,
      storeArgIndex: null,
      modes: [0, 0],
      args: [1, 3],
    });
  });
  it('should decode 1105,3,4 to {5,JTRU,2,[1,1],[3,4]}', () => {
    const program = [1105,3,4,33];
    expect(intcode.decode(program)).to.eql({
      opcode: 5,
      opcodeName: 'JTRU',
      argCount: 2,
      storeArgIndex: null,
      modes: [1, 1],
      args: [3, 4],
    });
  });
  it('should decode 106,0,7 to {6,JFAL,2,[1,0],[0,7]}', () => {
    const program = [106,0,7];
    expect(intcode.decode(program)).to.eql({
      opcode: 6,
      opcodeName: 'JFAL',
      argCount: 2,
      storeArgIndex: null,
      modes: [1, 0],
      args: [0, 7],
    });
  });
  it('should decode 1006,1,8 to {6,JFAL,2,[0,1],[1,8]}', () => {
    const program = [1006,1,8,33];
    expect(intcode.decode(program)).to.eql({
      opcode: 6,
      opcodeName: 'JFAL',
      argCount: 2,
      storeArgIndex: null,
      modes: [0, 1],
      args: [1, 8],
    });
  });
  it('should decode 7,0,0,0 to {7,LT,3,[0,0,0],[0,0,0]}', () => {
    const program = [7,0,0,0,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 7,
      opcodeName: 'LT',
      argCount: 3,
      storeArgIndex: 2,
      modes: [0, 0, 0],
      args: [0, 0, 0],
    });
  });
  it('should decode 1107,612,763,651 to {7,LT,3,[1,1,0],[612,763,651]}', () => {
    const program = [1107,612,763,651,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 7,
      opcodeName: 'LT',
      argCount: 3,
      storeArgIndex: 2,
      modes: [1, 1, 0],
      args: [612, 763, 651],
    });
  });
  it('should decode 8,3,1,5 to {8,EQ,3,[0,0,0],[3,1,5]}', () => {
    const program = [8,3,1,5];
    expect(intcode.decode(program)).to.eql({
      opcode: 8,
      opcodeName: 'EQ',
      argCount: 3,
      storeArgIndex: 2,
      modes: [0, 0, 0],
      args: [3, 1, 5],
    });
  });
  it('should decode 1008,4,3,4 to {8,EQ,3,[0,1,0],[4,3,4]}', () => {
    const program = [1008,4,3,4,33];
    expect(intcode.decode(program)).to.eql({
      opcode: 8,
      opcodeName: 'EQ',
      argCount: 3,
      storeArgIndex: 2,
      modes: [0, 1, 0],
      args: [4, 3, 4],
    });
  });
  it('should decode 99 to {99,HALT,0,[],[]}', () => {
    const program = [99,77];
    expect(intcode.decode(program)).to.eql({
      opcode: 99,
      opcodeName: 'HALT',
      argCount: 0,
      storeArgIndex: null,
      modes: [],
      args: [],
    });
  });
  it('should throw an exception for invalid immediate mode [ADD]', () => {
    const program = [11101,1,2,3];
    const call = () => { intcode.decode(program); };
    expect(call).to.throw(Error, 'immediate mode is invalid for store argument');
  });
  it('should throw an exception for invalid immediate mode [IN]', () => {
    const program = [103,4];
    const call = () => { intcode.decode(program); };
    expect(call).to.throw(Error, 'immediate mode is invalid for store argument');
  });
});
describe('intcode instructionString tests', () => {
  it('should render 1001,1,2,3 as "ADD M1,2,M3"', () => {
    const program = [1001,1,2,3];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('ADD M1,2,M3');
  });
  it('should render 1201,1,2,3 as "ADD *1,2,M3"', () => {
    const program = [1201,1,2,3];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('ADD *1,2,M3');
  });
  it('should render 102,3,1,5 as "MUL 3,M1,M5"', () => {
    const program = [102,3,1,5];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('MUL 3,M1,M5');
  });
  it('should render 2102,3,1,5 as "MUL 3,*1,M5"', () => {
    const program = [2102,3,1,5];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('MUL 3,*1,M5');
  });
  it('should render 4.50 as "OUT M50"', () => {
    const program = [4,50];
    expect(intcode.instructionString(intcode.decode(program))).to.eql('OUT M50');
  });
});
