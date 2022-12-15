'use strict';
const expect = require('chai').expect;
const beacon = require('../src/beacon');
const exampleInput = 'Sensor at x=2, y=18: closest beacon is at x=-2, y=15\nSensor at x=9, y=16: closest beacon is at x=10, y=16\nSensor at x=13, y=2: closest beacon is at x=15, y=3\nSensor at x=12, y=14: closest beacon is at x=10, y=16\nSensor at x=10, y=20: closest beacon is at x=10, y=16\nSensor at x=14, y=17: closest beacon is at x=10, y=16\nSensor at x=8, y=7: closest beacon is at x=2, y=10\nSensor at x=2, y=0: closest beacon is at x=2, y=10\nSensor at x=0, y=11: closest beacon is at x=2, y=10\nSensor at x=20, y=14: closest beacon is at x=25, y=17\nSensor at x=17, y=20: closest beacon is at x=21, y=22\nSensor at x=16, y=7: closest beacon is at x=15, y=3\nSensor at x=14, y=3: closest beacon is at x=15, y=3\nSensor at x=20, y=1: closest beacon is at x=15, y=3\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const expected = {
      sensor: {y: 18, x: 2},
      beacon: {y: 15, x: -2},
      range: 7,
    };
    expect(beacon.parseLine('Sensor at x=2, y=18: closest beacon is at x=-2, y=15')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {sensor: {y: 18, x: 2}, beacon: {y: 15, x: -2}, range: 7},
      {sensor: {y: 16, x: 9}, beacon: {y: 16, x: 10}, range: 1},
      {sensor: {y: 2, x: 13}, beacon: {y: 3, x: 15}, range: 3},
      {sensor: {y: 14, x: 12}, beacon: {y: 16, x: 10}, range: 4},
      {sensor: {y: 20, x: 10}, beacon: {y: 16, x: 10}, range: 4},
      {sensor: {y: 17, x: 14}, beacon: {y: 16, x: 10}, range: 5},
      {sensor: {y: 7, x: 8}, beacon: {y: 10, x: 2}, range: 9},
      {sensor: {y: 0, x: 2}, beacon: {y: 10, x: 2}, range: 10},
      {sensor: {y: 11, x: 0}, beacon: {y: 10, x: 2}, range: 3},
      {sensor: {y: 14, x: 20}, beacon: {y: 17, x: 25}, range: 8},
      {sensor: {y: 20, x: 17}, beacon: {y: 22, x: 21}, range: 6},
      {sensor: {y: 7, x: 16}, beacon: {y: 3, x: 15}, range: 5},
      {sensor: {y: 3, x: 14}, beacon: {y: 3, x: 15}, range: 1},
      {sensor: {y: 1, x: 20}, beacon: {y: 3, x: 15}, range: 7},
    ];
    expect(beacon.parse(exampleInput)).to.eql(expected);
  });
});
describe('location tests', () => {
  it('should compute no-beacon location on 1 row correctly', () => {
    const pair = beacon.parseLine('Sensor at x=8, y=7: closest beacon is at x=2, y=10');
    const expected = [
      {y: 10, x: 2},
      {y: 10, x: 3},
      {y: 10, x: 4},
      {y: 10, x: 5},
      {y: 10, x: 6},
      {y: 10, x: 7},
      {y: 10, x: 8},
      {y: 10, x: 9},
      {y: 10, x: 10},
      {y: 10, x: 11},
      {y: 10, x: 12},
      {y: 10, x: 13},
      {y: 10, x: 14},
    ];
    expect(beacon.notAt(pair, 10)).to.eql(expected);
  });
  it('should compute count of no-beacon locations on 1 row correctly', () => {
    const pairs = beacon.parse(exampleInput);
    expect(beacon.countNotAt(pairs, 10)).to.equal(26);
  });
  it('should find pairs w/sensors covering column (x=0)', () => {
    const expected = [
      {sensor: {y: 18, x: 2}, beacon: {y: 15, x: -2}, range: 7},
      {sensor: {y: 7, x: 8}, beacon: {y: 10, x: 2}, range: 9},
      {sensor: {y: 0, x: 2}, beacon: {y: 10, x: 2}, range: 10},
      {sensor: {y: 11, x: 0}, beacon: {y: 10, x: 2}, range: 3},
    ];
    const pairs = beacon.parse(exampleInput);
    expect(beacon.pairsCoveringColumn(pairs, 0)).to.eql(expected);
  });
  it('should find pairs w/sensors covering column (x=14)', () => {
    const expected = [
      {sensor: {y: 2, x: 13}, beacon: {y: 3, x: 15}, range: 3},
      {sensor: {y: 14, x: 12}, beacon: {y: 16, x: 10}, range: 4},
      {sensor: {y: 20, x: 10}, beacon: {y: 16, x: 10}, range: 4},
      {sensor: {y: 17, x: 14}, beacon: {y: 16, x: 10}, range: 5},
      {sensor: {y: 7, x: 8}, beacon: {y: 10, x: 2}, range: 9},
      {sensor: {y: 14, x: 20}, beacon: {y: 17, x: 25}, range: 8},
      {sensor: {y: 20, x: 17}, beacon: {y: 22, x: 21}, range: 6},
      {sensor: {y: 7, x: 16}, beacon: {y: 3, x: 15}, range: 5},
      {sensor: {y: 3, x: 14}, beacon: {y: 3, x: 15}, range: 1},
      {sensor: {y: 1, x: 20}, beacon: {y: 3, x: 15}, range: 7},
    ];
    const pairs = beacon.parse(exampleInput);
    expect(beacon.pairsCoveringColumn(pairs, 14)).to.eql(expected);
  });
  it('should find pairs w/sensors covering column (x=20)', () => {
    const expected = [
      {sensor: {y: 14, x: 20}, beacon: {y: 17, x: 25}, range: 8},
      {sensor: {y: 20, x: 17}, beacon: {y: 22, x: 21}, range: 6},
      {sensor: {y: 7, x: 16}, beacon: {y: 3, x: 15}, range: 5},
      {sensor: {y: 1, x: 20}, beacon: {y: 3, x: 15}, range: 7},
    ];
    const pairs = beacon.parse(exampleInput);
    expect(beacon.pairsCoveringColumn(pairs, 20)).to.eql(expected);
  });
  it('should find row ranges covering column (x=0)', () => {
    const expected = [
      [13, 23],
      [6, 8],
      [-8, 8],
      [8, 14],
    ];
    const pairs = beacon.pairsCoveringColumn(beacon.parse(exampleInput), 0);
    expect(beacon.rowRangesCoveringColumn(pairs, 0)).to.eql(expected);
  });
  it('should find row ranges covering column (x=14)', () => {
    const expected = [
      [0, 4],
      [12, 16],
      [20, 20],
      [12, 22],
      [4, 10],
      [12, 16],
      [17, 23],
      [4, 10],
      [2, 4],
      [0, 2],
    ];
    const pairs = beacon.pairsCoveringColumn(beacon.parse(exampleInput), 14);
    expect(beacon.rowRangesCoveringColumn(pairs, 14)).to.eql(expected);
  });
  it('should find row ranges covering column (x=20)', () => {
    const expected = [
      [6, 22],
      [17, 23],
      [6, 8],
      [-6, 8],
    ];
    const pairs = beacon.pairsCoveringColumn(beacon.parse(exampleInput), 20);
    expect(beacon.rowRangesCoveringColumn(pairs, 20)).to.eql(expected);
  });
  it('should clip row ranges correctly', () => {
    const ranges = [
      [6, 22],
      [17, 23],
      [6, 8],
      [-6, 8],
    ];
    const expected = [
      [6, 20],
      [17, 20],
      [6, 8],
      [0, 8],
    ];
    expect(beacon.clipRanges(ranges, 20)).to.eql(expected);
  });
  it('should detect range overlap and merge correctly', () => {
    const tests = [
      // touching
      {a: [0, 2], b: [3, 5], overlap: true, result: [0, 5]},
      {a: [10, 13], b: [6, 9], overlap: true, result: [6, 13]},
      // gap of 1
      {a: [0, 2], b: [4, 5], overlap: false},
      {a: [0, 1], b: [3, 5], overlap: false},
      {a: [10, 13], b: [6, 8], overlap: false},
      {a: [11, 13], b: [6, 9], overlap: false},
      // contained
      {a: [0, 2], b: [0, 2], overlap: true, result: [0, 2]},
      {a: [0, 2], b: [0, 3], overlap: true, result: [0, 3]},
      {a: [10, 13], b: [10, 13], overlap: true, result: [10, 13]},
      {a: [10, 13], b: [9, 13], overlap: true, result: [9, 13]},
      // overlapping
      {a: [0, 5], b: [1, 6], overlap: true, result: [0, 6]},
      {a: [8, 13], b: [7, 12], overlap: true, result: [7, 13]},
    ];
    for (const test of tests) {
      expect(beacon.rangesOverlap(test.a, test.b)).to.equal(test.overlap);
      if (test.overlap) {
        expect(beacon.mergeRange(test.a, test.b)).to.eql(test.result);
      }
    }
  });
  it('should merge row ranges correctly (x=0)', () => {
    const ranges = [
      [13, 20],
      [6, 8],
      [0, 8],
      [8, 14],
    ];
    expect(beacon.mergeRanges(ranges)).to.eql([[0, 20]]);
  });
  it('should merge row ranges correctly (x=14)', () => {
    const ranges = [
      [0, 4],
      [12, 16],
      [20, 20],
      [12, 20],
      [4, 10],
      [12, 16],
      [17, 20],
      [4, 10],
      [2, 4],
      [0, 2],
    ];
    const expected = [
      [0, 10],
      [12, 20],
    ];
    const actual = beacon.mergeRanges(ranges).sort((a, b) => {
      return (a[0] < b[0]) ? -1 : ((a[0] > b[0]) ? 1 : 0);
    });
    expect(actual).to.eql(expected);
  });
  it('should merge row ranges correctly (x=20)', () => {
    const ranges = [
      [6, 20],
      [17, 20],
      [6, 8],
      [0, 8],
    ];
    expect(beacon.mergeRanges(ranges)).to.eql([[0, 20]]);
  });
  it('should not find beacon at x=0', () => {
    const pairs = beacon.parse(exampleInput);
    expect(beacon.findBeaconAtColumn(pairs, 0, 20)).to.equal(null);
  });
  it('should find beacon at x=14', () => {
    const pairs = beacon.parse(exampleInput);
    expect(beacon.findBeaconAtColumn(pairs, 14, 20)).to.equal(11);
  });
  it('should not find beacon at x=20', () => {
    const pairs = beacon.parse(exampleInput);
    expect(beacon.findBeaconAtColumn(pairs, 20, 20)).to.equal(null);
  });
});
