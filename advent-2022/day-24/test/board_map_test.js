'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const BoardMap = require('../src/board_map');
const exampleInput = `#.#####
#.....#
#>....#
#.....#
#...v.#
#.....#
#####.#`;
describe('Board construction tests', () => {
  it('should parse a whole input set correctly', () => {
    const map = new BoardMap(exampleInput);
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
describe('Board construction tests (pathological boards)', () => {
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
