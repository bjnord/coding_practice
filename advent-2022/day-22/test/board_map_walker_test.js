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
  it('should calculate direction/facing correctly after turns', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const tests = [
      {way: -90, newDir: 0, facing: 3, facingChar: '^'},
      {way: -90, newDir: 270, facing: 2, facingChar: '<'},
      {way: 90, newDir: 0},
      {way: -90, newDir: 270},
      {way: -90, newDir: 180, facing: 1, facingChar: 'v'},
      {way: -90, newDir: 90, facing: 0, facingChar: '>'},
      {way: -90, newDir: 0},
      {way: -90, newDir: 270},
      {way: 90, newDir: 0},
      {way: 90, newDir: 90},
      {way: 90, newDir: 180},
      {way: 90, newDir: 270},
      {way: 90, newDir: 0},
      // (180deg turns are for unit tests)
      {way: 180, newDir: 180},
      {way: 180, newDir: 0},
      {way: 90, newDir: 90},
      {way: 180, newDir: 270},
      {way: 180, newDir: 90},
    ];
    for (const test of tests) {
      const dir = walker.direction();
      expect(walker.turn(test.way), `walker turn ${test.way} from ${dir}`).to.equal(test.newDir);
      expect(walker.direction(), `walker newDir ${test.way} from ${dir}`).to.equal(test.newDir);
      if (test.facing !== undefined) {
        expect(walker.facing(), `walker facing ${test.way} from ${dir}`).to.equal(test.facing);
        expect(walker.facingChar(), `walker facing-char ${test.way} from ${dir}`).to.equal(test.facingChar);
      }
    }
  });
  it('should throw exception for invalid turn direction', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const badTurnFn = () => { walker.turn(45); };
    expect(badTurnFn).to.throw(SyntaxError);
  });
});
describe('BoardMapWalker movement tests', () => {
  it('should calculate position correctly after moves', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    const tests = [
      {turn: -90},
      {move: 1, newPos: {y: 11, x: 8}},
      {move: 5, newPos: {y: 6, x: 8}},
      {turn: 90},
      {move: 3, newPos: {y: 6, x: 11}},  // A
      {move: 1, newPos: {y: 6, x: 0}},   // B
      {turn: 90},
      {move: 1, newPos: {y: 7, x: 0}},
      {turn: -90},
      {move: 5, newPos: {y: 7, x: 5}},   // C
      {turn: 90},
      {move: 1, newPos: {y: 4, x: 5}},   // D
    ];
    for (const test of tests) {
      if (test.turn) {
        walker.turn(test.turn);
      } else {
        const pos = walker.positionString();
        expect(walker.move(test.move), `walker move ${test.move} from ${pos}`).to.eql(test.newPos);
        expect(walker.position(), `walker newPos ${test.move} from ${pos}`).to.eql(test.newPos);
      }
    }
  });
  it('should calculate position correctly after walls', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    const tests = [
      {move: 2, newPos: {y: 0, x: 10}},
      {move: 3, newPos: {y: 0, x: 10}},  // bump R 3x
      {turn: 180},
      {move: 2, newPos: {y: 0, x: 8}},
      {move: 3, newPos: {y: 0, x: 8}},   // bump L 3x (wrap)
      {turn: 180},
      {move: 2, newPos: {y: 0, x: 10}},
      {turn: 90},
      {move: 2, newPos: {y: 2, x: 10}},
      {turn: -90},
      {move: 1, newPos: {y: 2, x: 11}},
      {move: 3, newPos: {y: 2, x: 11}},  // bump R 3x (wrap)
      {turn: 90},
      {move: 1, newPos: {y: 3, x: 11}},
      {turn: -90},
      {move: 1, newPos: {y: 3, x: 8}},
      {turn: -90},
      {move: 3, newPos: {y: 3, x: 8}},   // bump U 3x
      {turn: 180},
      {move: 1, newPos: {y: 4, x: 8}},
      {turn: -90},
      {move: 2, newPos: {y: 4, x: 10}},
      {move: 1, newPos: {y: 4, x: 10}},  // bump R
      {turn: -90},
      {move: 5, newPos: {y: 11, x: 10}},
      {turn: 90},
      {move: 1, newPos: {y: 11, x: 11}},
      {turn: 90},
      {move: 2, newPos: {y: 11, x: 11}}, // bump D 2x (wrap)
    ];
    for (const test of tests) {
      if (test.turn) {
        walker.turn(test.turn);
      } else {
        const pos = walker.positionString();
        expect(walker.move(test.move), `walker move ${test.move} from ${pos}`).to.eql(test.newPos);
        expect(walker.position(), `walker newPos ${test.move} from ${pos}`).to.eql(test.newPos);
      }
    }
  });
  it('should throw exception for invalid move distance', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const badMoveFn = () => { walker.move(0); };
    expect(badMoveFn).to.throw(SyntaxError);
  });
});
