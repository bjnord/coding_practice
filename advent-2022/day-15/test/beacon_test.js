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
    const expected =
    [
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
});
