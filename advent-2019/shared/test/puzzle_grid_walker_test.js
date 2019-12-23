'use strict';
const expect = require('chai').expect;
const PuzzleGrid = require('../src/puzzle_grid');
const PuzzleGridWalker = require('../src/puzzle_grid_walker');

describe('puzzle grid walker tests [common checks]', () => {
  let tinyGrid, tinyWalker;
  before(() => {
    tinyGrid = PuzzleGrid.from(['####', '#..#', '####'], {0: {render: '.', passable: true}, 1: {render: '#', passable: false}});
  });
  beforeEach(() => {
    tinyWalker = new PuzzleGridWalker(tinyGrid);
  });
  it('should throw exception with undefined callbacks', () => {
    const call = () => { tinyWalker.walk([1, 1]); };
    expect(call).to.throw(Error, 'at least one callback must be provided');
  });
  it('should throw exception with empty callbacks', () => {
    const call = () => { tinyWalker.walk([1, 1], {}); };
    expect(call).to.throw(Error, 'at least one callback must be provided');
  });
  it('should throw an exception if origin is impassable', () => {
    const call = () => { tinyWalker.walk([1, 0], {'movedTo': () => undefined}); };
    expect(call).to.throw(Error, 'origin is impassable');
  });
  it('should work even if no callbacks are called', () => {
    const call = () => { tinyWalker.walk([1, 1], {'magicHappened': () => undefined}); };
    expect(call).to.not.throw();
  });
});
describe('puzzle grid walker tests [no items, movedTo callback]', () => {
  const walkKey = {
    0: {name: 'floor', render: '.', passable: true},
    1: {name: 'vwall', render: '|', passable: false},
    2: {name: 'hwall', render: '-', passable: false},
    3: {name: 'junction', render: '+', passable: false},
  };
  const walkLines = [
    '+-------+---+-----+-+',
    '|.......|...|.....|.|',
    '|.--+--.|.|.|.|.|.|.|',
    '|...|...|.|...|.|...|',
    '+--.|.|.|.+---+-+---+',
    '|...|.|.|.|.....|...|',
    '|.+-+.|.|.|.--+.+-+.|',
    '|.|...|.|.....|...|.|',
    '|.+-+-+-+-+---+-+.|.|',
    '|...|.....|.....|...|',
    '+--.|.+--.|.|.--+--.|',
    '|.....|.....|.......|',
    '+-----+-----+-------+',
  ];
  let walkGrid, walker, walkVisited, walkLongestPathLength, walkMovedTo;
  beforeEach(() => {
    walkVisited = {};
    walkLongestPathLength = 0;
    // use destructuring to avoid lint "unused argument" errors
    // h/t <https://stackoverflow.com/a/58738236/291754>
    walkMovedTo = (...[pos, , steps]) => {
      const i = pos[0] * 256 + pos[1];
      walkVisited[i] = true;
      walkLongestPathLength = Math.max(walkLongestPathLength, steps);
    };
    walkGrid = PuzzleGrid.from(walkLines, walkKey);
    walker = new PuzzleGridWalker(walkGrid);
  });
  it('should visit all the squares', () => {
    walker.walk([1, 1], {
      movedTo: walkMovedTo,
    });
    expect(Object.keys(walkVisited).length).to.eql(119);
  });
  it('should find the farthest square visited (longest path)', () => {
    walker.walk([1, 1], {
      movedTo: walkMovedTo,
    });
    expect(walkLongestPathLength).to.eql(82);
  });
});
