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
describe('BoardMapWalker turning tests', () => {
  it('should calculate direction correctly after turns', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const tests = [
      {way: -90, newDir: 0},
      {way: -90, newDir: 270},
      {way: 90, newDir: 0},
      {way: -90, newDir: 270},
      {way: -90, newDir: 180},
      {way: -90, newDir: 90},
      {way: -90, newDir: 0},
      {way: -90, newDir: 270},
      {way: 90, newDir: 0},
      {way: 90, newDir: 90},
      {way: 90, newDir: 180},
      {way: 90, newDir: 270},
      {way: 90, newDir: 0},
    ];
    for (const test of tests) {
      const dir = walker.direction();
      expect(walker.turn(test.way), `walker turn ${test.way} from ${dir}`).to.equal(test.newDir);
      expect(walker.direction(), `walker newDir ${test.way} from ${dir}`).to.equal(test.newDir);
    }
  });
  it('should throw exception for invalid turn direction', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const badTurnFn = () => { walker.turn(45) };
    expect(badTurnFn).to.throw(SyntaxError);
  });
});
