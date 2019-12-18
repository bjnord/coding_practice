'use strict';
const expect = require('chai').expect;
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const pathAnalyzer = require('../src/path_analyzer');
describe('puzzle path analyzer tests', () => {
  const peKey = {
    0: {name: 'space', render: '.'},
    1: {name: 'scaffold', render: '#'},
    2: {name: 'intersection', render: 'O'},
  };
  it('should analyze the path properly [puzzle example #1]', () => {
    const puzzleExample1 = [
      '..#..........',
      '..#..........',
      '##O####...###',
      '#.#...#...#.#',
      '##O###O###O##',
      '..#...#...#..',
      '..#####...^..',
    ];
    const pe1 = PuzzleGrid.from(puzzleExample1, peKey);
    const pe1Expected = '4,R,2,R,2,R,12,R,2,R,6,R,4,R,4,R,6';
    // FIXME "[6, 10], 1" need to come from puzzle parse; use unknownType callback
    expect(pathAnalyzer.path(pe1, [6, 10], 1)).to.eql(pe1Expected);
  });
  it('should analyze the path properly [puzzle example #2]', () => {
    const puzzleExample2 = [
      '#######...#####',
      '#.....#...#...#',
      '#.....#...#...#',
      '......#...#...#',
      '......#...###.#',
      '......#.....#.#',
      '^#####O##...#.#',
      '......#.#...#.#',
      '......##O###O##',
      '........#...#..',
      '....####O####..',
      '....#...#......',
      '....#...#......',
      '....#...#......',
      '....#####......',
    ];
    const pe2 = PuzzleGrid.from(puzzleExample2, peKey);
    const pe2Expected = 'R,8,R,8,R,4,R,4,R,8,L,6,L,2,R,4,R,4,R,8,R,8,R,8,L,6,L,2';
    // FIXME "[6, 0], 1" need to come from puzzle parse; use unknownType callback
    expect(pathAnalyzer.path(pe2, [6, 0], 1)).to.eql(pe2Expected);
  });
});
