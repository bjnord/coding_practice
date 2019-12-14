'use strict';
const expect = require('chai').expect;
const refinery = require('../src/refinery');
describe('parsing tests', () => {
  // 10 ORE => 10 A
  // 1 ORE => 1 B
  // 7 A, 1 B => 1 C
  // 7 A, 1 C => 1 D
  // 7 A, 1 D => 1 E
  // 7 A, 1 E => 1 FUEL
  it('should parse ORE-only correctly', () => {
    const expected = {units: 1, chem: 'B', req: [{units: 10, chem: 'ORE'}]};
    expect(refinery.parseLine('10 ORE => 1 B\n')).to.eql(expected);
  });
  it('should parse one-chem correctly', () => {
    const expected = {units: 1, chem: 'C', req: [{units: 7, chem: 'A'}]};
    expect(refinery.parseLine('7 A => 1 C\n')).to.eql(expected);
  });
  it('should parse two-chem correctly', () => {
    const expected = {units: 1, chem: 'E', req: [{units: 7, chem: 'A'}, {units: 1, chem: 'D'}]};
    expect(refinery.parseLine('7 A, 1 D => 1 E\n')).to.eql(expected);
  });
  it('should parse FUEL correctly', () => {
    const expected = {units: 1, chem: 'FUEL', req: [{units: 7, chem: 'A'}, {units: 1, chem: 'E'}]};
    expect(refinery.parseLine('7 A, 1 E => 1 FUEL\n')).to.eql(expected);
  });
  it('should ignore extra spaces/tabs', () => {
    const expected = {units: 1, chem: 'D', req: [{units: 7, chem: 'A'}, {units: 1, chem: 'C'}]};
    expect(refinery.parseLine('   7 	 A ,   1  C  =>  1     D  \n')).to.eql(expected);
  });
  it('should throw an exception for invalid format (no arrow)', () => {
    const call = () => { refinery.parseLine('7 A, 1 E 1 FUEL\n'); };
    expect(call).to.throw(Error, 'invalid line format');
  });
  it('should throw an exception for invalid format (extra on left)', () => {
    const call = () => { refinery.parseLine('7 A, 1 E X => 1 FUEL\n'); };
    expect(call).to.throw(Error, 'invalid units/chemical "1 E X"');
  });
  it('should throw an exception for invalid format (extra on right)', () => {
    const call = () => { refinery.parseLine('7 A, 1 E => 1 Y FUEL\n'); };
    expect(call).to.throw(Error, 'invalid units/chemical "1 Y FUEL"');
  });
  it('should throw an exception for invalid format (non-numeric units on left)', () => {
    const call = () => { refinery.parseLine('7 A, Q E => 1 FUEL\n'); };
    expect(call).to.throw(Error, 'invalid units "Q"');
  });
  it('should throw an exception for invalid format (non-numeric units on right)', () => {
    const call = () => { refinery.parseLine('7 A, 1 E => @ FUEL\n'); };
    expect(call).to.throw(Error, 'invalid units "@"');
  });
  it('should parse a whole input set correctly [puzzle example #1]', () => {
    const expected = new Map([
      ['A', {units: 10, req: [{units: 10, chem: 'ORE'}]}],
      ['B', {units: 1, req: [{units: 1, chem: 'ORE'}]}],
      ['C', {units: 1, req: [{units: 7, chem: 'A'}, {units: 1, chem: 'B'}]}],
      ['D', {units: 1, req: [{units: 7, chem: 'A'}, {units: 1, chem: 'C'}]}],
      ['E', {units: 1, req: [{units: 7, chem: 'A'}, {units: 1, chem: 'D'}]}],
      ['FUEL', {units: 1, req: [{units: 7, chem: 'A'}, {units: 1, chem: 'E'}]}],
    ]);
    expect(refinery.parse('10 ORE => 10 A\n1 ORE => 1 B\n7 A, 1 B => 1 C\n7 A, 1 C => 1 D\n7 A, 1 D => 1 E\n7 A, 1 E => 1 FUEL\n')).to.eql(expected);
  });
  it('should throw an exception for duplicate output chemical', () => {
    const call = () => { refinery.parse('10 ORE => 10 A\n1 ORE => 1 B\n7 A, 1 B => 1 C\n7 A, 1 X => 1 C\n7 A, 1 C => 1 D\n'); };
    expect(call).to.throw(Error, 'duplicate output chemical "C"');
  });
});
