'use strict';
const expect = require('chai').expect;
const Scaffold = require('../src/scaffold');
describe('scaffold constructor tests [puzzle example]', () => {
  let scaffold;
  before(() => {
    // ..#..........
    // ..#..........
    // #######...###
    // #.#...#...#.#
    // #############
    // ..#...#...#..
    // ..#####...^..
    scaffold = new Scaffold('104,46,104,46,104,35,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,10,104,46,104,46,104,35,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,46,104,10,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,46,104,46,104,46,104,35,104,35,104,35,104,10,104,35,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,35,104,10,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,35,104,10,104,46,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,46,104,46,104,35,104,46,104,46,104,10,104,46,104,46,104,35,104,35,104,35,104,35,104,35,104,46,104,46,104,46,104,94,104,46,104,46,99');
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
