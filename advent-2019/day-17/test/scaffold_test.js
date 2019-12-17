'use strict';
const expect = require('chai').expect;
const Scaffold = require('../src/scaffold');

// ..#..........
// ..#..........
// #######...###
// #.#...#...#.#
// #############
// ..#...#...#..
// ..#####...^..
const puzzleExample = '104,46,104,46,104,35,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,10,104,46,104,46,104,35,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,10,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,46,104,46,104,46,104,35,104,35,104,35,104,10,104,35,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,35,104,10,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,10,104,46,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,46,104,10,104,46,104,46,104,35,104,35,104,35,104,35,104,35,104,46,104,46,104,46,104,94,104,46,104,46,99';

describe('scaffold constructor tests [puzzle example]', () => {
  let scaffold;
  before(() => {
    scaffold = new Scaffold(puzzleExample);
    scaffold.run();
  });
  it('should create the scaffold map correctly', () => {
    expect(scaffold._grid.get([0, 0])).to.eql(0);
    expect(scaffold._grid.get([0, 2])).to.eql(1);
    expect(scaffold._grid.get([0, 12])).to.eql(0);
    expect(scaffold._grid.get([0, 13])).to.be.undefined;
    expect(scaffold._grid.get([6, 0])).to.eql(0);
    expect(scaffold._grid.get([6, 10])).to.eql(1);
    expect(scaffold._grid.get([6, 12])).to.eql(0);
    expect(scaffold._grid.get([6, 13])).to.be.undefined;
    expect(scaffold._grid.get([7, 0])).to.be.undefined;
  });
  it('should set the initial vacuum robot position/location correctly', () => {
    expect(scaffold._position).to.eql([6, 10]);
    expect(scaffold._direction).to.eql(1);
  });
});
describe('scaffold constructor tests [robot tumbling]', () => {
  let scaffold;
  before(() => {
    // .X.
    scaffold = new Scaffold('104,46,104,88,104,46,99');
    scaffold.run();
  });
  it('should create the scaffold map correctly', () => {
    expect(scaffold._grid.get([0, 0])).to.eql(0);
    expect(scaffold._grid.get([0, 1])).to.eql(0);
    expect(scaffold._grid.get([0, 2])).to.eql(0);
    expect(scaffold._grid.get([0, 3])).to.be.undefined;
    expect(scaffold._grid.get([1, 0])).to.be.undefined;
  });
  it('should set the initial vacuum robot position/location correctly', () => {
    expect(scaffold._position).to.eql([0, 1]);
    expect(scaffold._direction).to.be.undefined;
  });
});
describe('scaffold intersection tests [puzzle example]', () => {
  it('should find the scaffold intersections correctly', () => {
    const scaffold = new Scaffold(puzzleExample);
    scaffold.run();
    scaffold.findIntersections();
    const expected = new Set([[2, 2], [4, 2], [4, 6], [4, 10]]);
    const actual = new Set(scaffold.intersections());
    expect(actual).to.eql(expected);
  });
});
