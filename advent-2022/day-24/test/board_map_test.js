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
    expect(map.height()).to.equal(7);
    expect(map.width()).to.equal(7);
    expect(map.startPosition()).to.eql({y: 0, x: 1});
    expect(map.endPosition()).to.eql({y: -6, x: 5});
    const expBlizzards = [
      {y: 2, x: 1, dir: {y: 0, x: 1}},
      {y: 4, x: 4, dir: {y: -1, x: 0}},
    ];
    expect(map.blizzards()).to.eql(expBlizzards);
  });
  it('should parse a whole input set correctly (complex example)', () => {
    const exampleInput2 = fs.readFileSync('input/example2.txt', 'utf8');
    const map2 = new BoardMap(exampleInput2);
    expect(map2.height()).to.equal(6);
    expect(map2.width()).to.equal(8);
    expect(map2.startPosition()).to.eql({y: 0, x: 1});
    expect(map2.endPosition()).to.eql({y: -5, x: 6});
    const expBlizzards2 = [
      {y: 1, x: 1, dir: {y: 0, x: 1}},
      {y: 1, x: 2, dir: {y: 0, x: 1}},
      {y: 1, x: 4, dir: {y: 0, x: -1}},
      {y: 1, x: 5, dir: {y: 1, x: 0}},
      {y: 1, x: 6, dir: {y: 0, x: -1}},
      //
      {y: 2, x: 2, dir: {y: 0, x: -1}},
      {y: 2, x: 5, dir: {y: 0, x: -1}},
      {y: 2, x: 6, dir: {y: 0, x: -1}},
      //
      {y: 3, x: 1, dir: {y: 0, x: 1}},
      {y: 3, x: 2, dir: {y: -1, x: 0}},
      {y: 3, x: 4, dir: {y: 0, x: 1}},
      {y: 3, x: 5, dir: {y: 0, x: -1}},
      {y: 3, x: 6, dir: {y: 0, x: 1}},
      //
      {y: 4, x: 1, dir: {y: 0, x: -1}},
      {y: 4, x: 2, dir: {y: 1, x: 0}},
      {y: 4, x: 3, dir: {y: -1, x: 0}},
      {y: 4, x: 4, dir: {y: 1, x: 0}},
      {y: 4, x: 5, dir: {y: 1, x: 0}},
      {y: 4, x: 6, dir: {y: 0, x: 1}},
    ];
    expect(map2.blizzards()).to.eql(expBlizzards2);
  });
});
describe('Board construction tests (pathological boards)', () => {
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
});
