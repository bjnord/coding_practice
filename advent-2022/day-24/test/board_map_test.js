'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const BoardMap = require('../src/board_map');
const exampleInput = [`
#.#####
#.....#
#>....#
#.....#
#...v.#
#.....#
#####.#
`, `
#.#####
#.....#
#.>...#
#.....#
#.....#
#...v.#
#####.#
`, `
#.#####
#...v.#
#..>..#
#.....#
#.....#
#.....#
#####.#
`, `
#.#####
#.....#
#...2.#
#.....#
#.....#
#.....#
#####.#
`, `
#.#####
#.....#
#....>#
#...v.#
#.....#
#.....#
#####.#
`];
describe('BoardMap construction tests', () => {
  it('should parse a whole input set correctly', () => {
    const map = new BoardMap(exampleInput[0]);
    expect(map.height(), 'example 1 height').to.equal(7);
    expect(map.width(), 'example 1 width').to.equal(7);
    expect(map.startPosition(), 'example 1 start pos').to.eql({y: 0, x: 1});
    expect(map.endPosition(), 'example 1 end pos').to.eql({y: -6, x: 5});
    const expBlizzards = [
      {pos: {y: -2, x: 1}, dir: {y: 0, x: 1}},
      {pos: {y: -4, x: 4}, dir: {y: -1, x: 0}},
    ];
    const actBlizzards = map.blizzards().map((blizzard) => {
      return {
        pos: blizzard.position(),
        dir: blizzard.direction(),
      };
    });
    expect(actBlizzards, 'example 1 blizzards').to.eql(expBlizzards);
  });
  it('should parse a whole input set correctly (complex example)', () => {
    const exampleInput2 = fs.readFileSync('input/example2.txt', 'utf8');
    const map2 = new BoardMap(exampleInput2);
    expect(map2.height(), 'example 2 height').to.equal(6);
    expect(map2.width(), 'example 2 width').to.equal(8);
    expect(map2.startPosition(), 'example 2 start pos').to.eql({y: 0, x: 1});
    expect(map2.endPosition(), 'example 2 end pos').to.eql({y: -5, x: 6});
    const expBlizzards2 = [
      {pos: {y: -1, x: 1}, dir: {y: 0, x: 1}},
      {pos: {y: -1, x: 2}, dir: {y: 0, x: 1}},
      {pos: {y: -1, x: 4}, dir: {y: 0, x: -1}},
      {pos: {y: -1, x: 5}, dir: {y: 1, x: 0}},
      {pos: {y: -1, x: 6}, dir: {y: 0, x: -1}},
      //
      {pos: {y: -2, x: 2}, dir: {y: 0, x: -1}},
      {pos: {y: -2, x: 5}, dir: {y: 0, x: -1}},
      {pos: {y: -2, x: 6}, dir: {y: 0, x: -1}},
      //
      {pos: {y: -3, x: 1}, dir: {y: 0, x: 1}},
      {pos: {y: -3, x: 2}, dir: {y: -1, x: 0}},
      {pos: {y: -3, x: 4}, dir: {y: 0, x: 1}},
      {pos: {y: -3, x: 5}, dir: {y: 0, x: -1}},
      {pos: {y: -3, x: 6}, dir: {y: 0, x: 1}},
      //
      {pos: {y: -4, x: 1}, dir: {y: 0, x: -1}},
      {pos: {y: -4, x: 2}, dir: {y: 1, x: 0}},
      {pos: {y: -4, x: 3}, dir: {y: -1, x: 0}},
      {pos: {y: -4, x: 4}, dir: {y: 1, x: 0}},
      {pos: {y: -4, x: 5}, dir: {y: 1, x: 0}},
      {pos: {y: -4, x: 6}, dir: {y: 0, x: 1}},
    ];
    const actBlizzards2 = map2.blizzards().map((blizzard) => {
      return {
        pos: blizzard.position(),
        dir: blizzard.direction(),
      };
    });
    expect(actBlizzards2, 'example 2 blizzards').to.eql(expBlizzards2);
  });
});
describe('BoardMap construction tests (pathological boards)', () => {
  it('should detect invalid cell characater', () => {
    const inputBadCell = '#.###\n#.>E#\n###.#\n';
    const badCellFn = () => { new BoardMap(inputBadCell); };
    expect(badCellFn, 'invalid cell char').to.throw(SyntaxError);
  });
  it('should detect missing start row', () => {
    const inputMissingStart = '#.<.#\n###.#\n';
    const missingStartFn = () => { new BoardMap(inputMissingStart); };
    expect(missingStartFn, 'missing start row').to.throw(SyntaxError);
  });
  it('should detect missing end row', () => {
    const inputMissingEnd = '#.###\n#.>.#\n';
    const missingEndFn = () => { new BoardMap(inputMissingEnd); };
    expect(missingEndFn, 'missing end row').to.throw(SyntaxError);
  });
  it('should detect rows after end row', () => {
    const inputRowsAfterEnd = '#.###\n#.>.#\n###.#\n#..^#\n';
    const rowsAfterEndFn = () => { new BoardMap(inputRowsAfterEnd); };
    expect(rowsAfterEndFn, 'middle end row').to.throw(SyntaxError);
  });
  it('should detect start row with no door', () => {
    const inputBadStart = '#####\n#.v.#\n###.#\n';
    const badStartFn = () => { new BoardMap(inputBadStart); };
    expect(badStartFn, 'start row with no door').to.throw(SyntaxError);
  });
  it('should detect end row with no door', () => {
    const inputBadEnd = '#.###\n#.v.#\n#####\n';
    const badEndFn = () => { new BoardMap(inputBadEnd); };
    expect(badEndFn, 'end row with no door').to.throw(SyntaxError);
  });
});
describe('BoardMap blizzard movement tests', () => {
  it('should move blizzards correctly', () => {
    const map = new BoardMap(exampleInput[0]);
    const expBlizzardPos1 = [
      {y: -2, x: 2},
      {y: -5, x: 4},
    ];
    const expBlizzardPos2 = [
      {y: -2, x: 3},
      {y: -1, x: 4},
    ];
    map.moveBlizzards();
    expect(map.blizzards().map((b) => b.position()), 'example 1 minute 1 pos').to.eql(expBlizzardPos1);
    map.moveBlizzards();
    expect(map.blizzards().map((b) => b.position()), 'example 1 minute 2 pos').to.eql(expBlizzardPos2);
  });
});
describe('BoardMap blizzard matrix tests', () => {
  it('should construct a blizzard map correctly', () => {
    const map = new BoardMap(exampleInput[0]);
    const expBlizMatrix0 = [
      [-1, -1, -1, -1, -1, -1, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  1,  0,  0,  0,  0, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  0,  0,  0,  1,  0, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1, -1, -1, -1, -1, -1, -1],
    ];
    const expBlizMatrix1 = [
      [-1, -1, -1, -1, -1, -1, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  0,  1,  0,  0,  0, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  0,  0,  0,  1,  0, -1],
      [-1, -1, -1, -1, -1, -1, -1],
    ];
    const expBlizMatrix3 = [
      [-1, -1, -1, -1, -1, -1, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  0,  0,  0,  2,  0, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1,  0,  0,  0,  0,  0, -1],
      [-1, -1, -1, -1, -1, -1, -1],
    ];
    expect(map.blizzardMatrix(), 'example 1 initial matrix').to.eql(expBlizMatrix0);
    map.moveBlizzards();
    expect(map.blizzardMatrix(), 'example 1 minute 1 matrix').to.eql(expBlizMatrix1);
    map.moveBlizzards();
    map.moveBlizzards();
    expect(map.blizzardMatrix(), 'example 1 minute 3 matrix').to.eql(expBlizMatrix3);
  });
});
describe('BoardMap dump generation tests', () => {
  it('should construct a blizzard map correctly', () => {
    const map = new BoardMap(exampleInput[0]);
    let t = 0;
    for (; t < 5; t++) {
      expect(map.blizzardDump().trim(), `example 1 minute ${t} dump`).to.equal(exampleInput[t].trim());
      map.moveBlizzards();
    }
    expect(map.blizzardDump().trim(), `example 1 minute ${t} dump`).to.equal(exampleInput[0].trim());
  });
});
