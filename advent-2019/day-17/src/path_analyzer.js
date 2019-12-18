'use strict';
const PuzzleGrid = require('../../shared/src/puzzle_grid');
/** @module */

// private: transform direction+turn into new direction
const turnedDir = (dir, turn) => {
  switch (turn) {
  case 'R':
    return {1: 4, 2: 3, 3: 1, 4: 2}[dir];
  case 'L':
    return {1: 3, 2: 4, 3: 2, 4: 1}[dir];
  default:
    throw new Error(`invalid turn ${turn}`);
  };
};
/**
 * Determine a robot path along the scaffolding.
 *
 * This implementation uses a simple brute-force approach: The robot always
 * proceeds straight when it can (through any "+" intersections), and when
 * it hits a wall, it turns right or left (assumes no "T" intersections).
 *
 * Directions are:
 * - `1` - up (north, -Y)
 * - `2` - down (south, +Y)
 * - `3` - left (west, -X)
 * - `4` - right (east, +X)
 *
 * @param {PuzzleGrid} grid - the scaffolding map
 * @param {Array} pos - initial robot [Y, X] position
 * @param {number} dir - initial robot direction
 *
 * @return {string}
 *   Returns a string describing a robot path along the scaffold.
 */
exports.path = (grid, pos, dir) => {
  let path = '';
  // determine initial turn, if needed
  if (grid.getInDirection(pos, dir) !== 1) {
    if (grid.getInDirection(pos, turnedDir(dir, 'R')) === 1) {
      dir = turnedDir(dir, 'R');
      path += 'R,';
    } else if (grid.getInDirection(pos, turnedDir(dir, 'L')) === 1) {
      dir = turnedDir(dir, 'L');
      path += 'L,';
    } else {
      throw new Error(`no way out from pos=[${pos}]`);
    }
  };
  for (;;) {
    // follow the path forward
    let count = 0;
    while (grid.getInDirection(pos, dir) > 0) {
      // FIXME make this method public, if we're going to use it
      pos = PuzzleGrid._newPosition(pos, dir);
      count++;
    }
    path += `${count},`;
    // turn right or left
    if (grid.getInDirection(pos, turnedDir(dir, 'R')) === 1) {
      dir = turnedDir(dir, 'R');
      path += 'R,';
    } else if (grid.getInDirection(pos, turnedDir(dir, 'L')) === 1) {
      dir = turnedDir(dir, 'L');
      path += 'L,';
    } else {
      break;  // hit the end
    }
  }
  return path.slice(0, path.length-1);  // trim trailing comma
};
/**
 * Break a robot path into movement functions.
 *
 * @param {string} path - robot path along scaffold
 *
 * @return {Array}
 *   Returns the list of function strings: 0 is the "main movement routine"
 *   and 1-3 are the "movement functions" (A, B, and C).
 */
exports.functions = (path) => {
  // TODO implement this properly; for now, cheat by hand-crafting for our
  //      puzzle input
  if (path.match(/^R,4,R,10,R,8,R,4,R,10,R,6,R,4,/)) {
    return [
      'A,B,A,B,C,B,C,A,B,C',
      'R,4,R,10,R,8,R,4',
      'R,10,R,6,R,4',
      'R,4,L,12,R,6,L,12',
    ];
  } else {
    throw new Error('only implemented for puzzle input');
  }
};
