'use strict';
const expect = require('chai').expect;
const forest = require('../src/forest');
const exampleInput = '30373\n25512\n65332\n33549\n35390\n';
describe('parsing tests', () => {
  it('should parse a whole input set correctly', () => {
    const expected = [
      [3, 0, 3, 7, 3],
      [2, 5, 5, 1, 2],
      [6, 5, 3, 3, 2],
      [3, 3, 5, 4, 9],
      [3, 5, 3, 9, 0],
    ];
    expect(forest.parse(exampleInput)).to.eql(expected);
  });
});
describe('visibility tests', () => {
  it('should determine if tree is visible', () => {
    const grid = forest.parse(exampleInput);
    // All of the trees around the edge of the grid are visible - since they are already on the edge, there are no trees to block the view.
    expect(forest.isVisible(grid, 0, 1)).to.equal(true);
    expect(forest.isVisible(grid, 1, 4)).to.equal(true);
    expect(forest.isVisible(grid, 4, 3)).to.equal(true);
    expect(forest.isVisible(grid, 3, 0)).to.equal(true);
    // The top-left 5 is visible from the left and top. (It isn't visible from the right or bottom since other trees of height 5 are in the way.)
    expect(forest.isVisible(grid, 1, 1)).to.equal(true);
    // The top-middle 5 is visible from the top and right.
    expect(forest.isVisible(grid, 1, 2)).to.equal(true);
    // The top-right 1 is not visible from any direction; for it to be visible, there would need to only be trees of height 0 between it and an edge.
    expect(forest.isVisible(grid, 1, 3)).to.equal(false);
    // The left-middle 5 is visible, but only from the right.
    expect(forest.isVisible(grid, 2, 1)).to.equal(true);
    // The center 3 is not visible from any direction; for it to be visible, there would need to be only trees of at most height 2 between it and an edge.
    expect(forest.isVisible(grid, 2, 2)).to.equal(false);
    // The right-middle 3 is visible from the right.
    expect(forest.isVisible(grid, 2, 3)).to.equal(true);
    // In the bottom row, the middle 5 is visible, but the 3 and 4 are not.
    expect(forest.isVisible(grid, 3, 1)).to.equal(false);
    expect(forest.isVisible(grid, 3, 2)).to.equal(true);
    expect(forest.isVisible(grid, 3, 3)).to.equal(false);
  });
  it('should determine how many trees are visible', () => {
    const grid = forest.parse(exampleInput);
    expect(forest.nVisible(grid)).to.equal(21);
  });
  it('should calculate scenic scores correctly', () => {
    const grid = forest.parse(exampleInput);
    // puzzle examples:
    expect(forest.scenicScore(grid, 1, 2)).to.equal(4);
    expect(forest.scenicScore(grid, 3, 2)).to.equal(8);
    // "If a tree is right on the edge, at least one of its viewing distances will be zero."
    expect(forest.scenicScore(grid, 0, 2)).to.equal(0);
    expect(forest.scenicScore(grid, 2, 4)).to.equal(0);
    expect(forest.scenicScore(grid, 4, 2)).to.equal(0);
    expect(forest.scenicScore(grid, 2, 0)).to.equal(0);
  });
});
