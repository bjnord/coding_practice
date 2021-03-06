'use strict';
const expect = require('chai').expect;
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const Vacuum = require('../src/vacuum');
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
    const vacuum1 = new Vacuum(pe1, [6, 10], '^');
    expect(pathAnalyzer.path(vacuum1)).to.eql(pe1Expected);
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
    const vacuum2 = new Vacuum(pe2, [6, 0], '^');
    expect(pathAnalyzer.path(vacuum2)).to.eql(pe2Expected);
  });
});
describe('puzzle path function breaker tests', () => {
  it('should break the path properly [puzzle example #1]');  // TODO
  it('should break the path properly [puzzle example #2]');  // TODO
});
