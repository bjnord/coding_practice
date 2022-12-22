'use strict';
const expect = require('chai').expect;
const BoardMap = require('../src/board_map');
const BoardMapWalker = require('../src/board_map_walker');
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
        ......#.`;
describe('BoardMapWalker constructor tests', () => {
  it('should get the correct initial state', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    expect(walker.position(), 'walker position').to.eql({y: 0, x: 8});
    expect(walker.direction(), 'walker direction').to.eql(90);
  });
});
