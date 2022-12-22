'use strict';
const expect = require('chai').expect;
const gps = require('../src/gps');
const exampleInput = `        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5`;
describe('parsing tests', () => {
  it('should parse steps correctly', () => {
    const expected = [
      {move: 10},
      {turn: 90},
      {move: 5},
      {turn: -90},
      {move: 5},
      {turn: 90},
      {move: 10},
      {turn: -90},
      {move: 4},
      {turn: 90},
      {move: 5},
      {turn: -90},
      {move: 5},
    ];
    expect(gps.parseSteps('10R5L5R10L4R5L5')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const notes = gps.parse(exampleInput);
    expect(notes.steps.length).to.equal(13);
    expect(notes.map.cellIsWall(1, 9)).to.be.true;
  });
});
