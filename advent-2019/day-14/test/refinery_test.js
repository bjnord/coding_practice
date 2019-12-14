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
describe('calculation tests', () => {
  it('should calculate ore amount correctly [puzzle example #1]', () => {
    // 10 ORE => 10 A
    // 1 ORE => 1 B
    // 7 A, 1 B => 1 C
    // 7 A, 1 C => 1 D
    // 7 A, 1 D => 1 E
    // 7 A, 1 E => 1 FUEL
    const inv = refinery.parse('10 ORE => 10 A\n1 ORE => 1 B\n7 A, 1 B => 1 C\n7 A, 1 C => 1 D\n7 A, 1 D => 1 E\n7 A, 1 E => 1 FUEL\n');
    expect(refinery.calculate(inv, {units: 1, chem: 'FUEL'})).to.eql(31);
  });
  it('should calculate ore amount correctly [puzzle example #2]', () => {
    // 9 ORE => 2 A
    // 8 ORE => 3 B
    // 7 ORE => 5 C
    // 3 A, 4 B => 1 AB
    // 5 B, 7 C => 1 BC
    // 4 C, 1 A => 1 CA
    // 2 AB, 3 BC, 4 CA => 1 FUEL
    const inv = refinery.parse('9 ORE => 2 A\n8 ORE => 3 B\n7 ORE => 5 C\n3 A, 4 B => 1 AB\n5 B, 7 C => 1 BC\n4 C, 1 A => 1 CA\n2 AB, 3 BC, 4 CA => 1 FUEL\n');
    expect(refinery.calculate(inv, {units: 1, chem: 'FUEL'})).to.eql(165);
  });
  it('should calculate ore amount correctly [puzzle example #3]', () => {
    // 157 ORE => 5 NZVS
    // 165 ORE => 6 DCFZ
    // 44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
    // 12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
    // 179 ORE => 7 PSHF
    // 177 ORE => 5 HKGWZ
    // 7 DCFZ, 7 PSHF => 2 XJWVT
    // 165 ORE => 2 GPVTF
    // 3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
    const inv = refinery.parse('157 ORE => 5 NZVS\n165 ORE => 6 DCFZ\n44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL\n12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ\n179 ORE => 7 PSHF\n177 ORE => 5 HKGWZ\n7 DCFZ, 7 PSHF => 2 XJWVT\n165 ORE => 2 GPVTF\n3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT\n');
    expect(refinery.calculate(inv, {units: 1, chem: 'FUEL'})).to.eql(13312);
  });
  it('should calculate ore amount correctly [puzzle example #4]', () => {
    // 2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
    // 17 NVRVD, 3 JNWZP => 8 VPVL
    // 53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
    // 22 VJHF, 37 MNCFX => 5 FWMGM
    // 139 ORE => 4 NVRVD
    // 144 ORE => 7 JNWZP
    // 5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
    // 5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
    // 145 ORE => 6 MNCFX
    // 1 NVRVD => 8 CXFTF
    // 1 VJHF, 6 MNCFX => 4 RFSQX
    // 176 ORE => 6 VJHF
    const inv = refinery.parse('2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG\n17 NVRVD, 3 JNWZP => 8 VPVL\n53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL\n22 VJHF, 37 MNCFX => 5 FWMGM\n139 ORE => 4 NVRVD\n144 ORE => 7 JNWZP\n5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC\n5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV\n145 ORE => 6 MNCFX\n1 NVRVD => 8 CXFTF\n1 VJHF, 6 MNCFX => 4 RFSQX\n176 ORE => 6 VJHF\n');
    expect(refinery.calculate(inv, {units: 1, chem: 'FUEL'})).to.eql(180697);
  });
  it('should calculate ore amount correctly [puzzle example #5]', () => {
    // 171 ORE => 8 CNZTR
    // 7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
    // 114 ORE => 4 BHXH
    // 14 VRPVC => 6 BMBT
    // 6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
    // 6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
    // 15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
    // 13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
    // 5 BMBT => 4 WPTQ
    // 189 ORE => 9 KTJDG
    // 1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
    // 12 VRPVC, 27 CNZTR => 2 XDBXC
    // 15 KTJDG, 12 BHXH => 5 XCVML
    // 3 BHXH, 2 VRPVC => 7 MZWV
    // 121 ORE => 7 VRPVC
    // 7 XCVML => 6 RJRHP
    // 5 BHXH, 4 VRPVC => 5 LTCX
    const inv = refinery.parse('171 ORE => 8 CNZTR\n7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL\n114 ORE => 4 BHXH\n14 VRPVC => 6 BMBT\n6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL\n6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT\n15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW\n13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW\n5 BMBT => 4 WPTQ\n189 ORE => 9 KTJDG\n1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP\n12 VRPVC, 27 CNZTR => 2 XDBXC\n15 KTJDG, 12 BHXH => 5 XCVML\n3 BHXH, 2 VRPVC => 7 MZWV\n121 ORE => 7 VRPVC\n7 XCVML => 6 RJRHP\n5 BHXH, 4 VRPVC => 5 LTCX\n');
    expect(refinery.calculate(inv, {units: 1, chem: 'FUEL'})).to.eql(2210736);
  });
});
