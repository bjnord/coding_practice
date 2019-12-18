'use strict';
const PuzzleGrid = require('../../shared/src/puzzle_grid');
/** @module */

const turnedDir = (dir, turn) => {
  switch (turn) {
  case 'R':
    return {1: 4, 2: 3, 3: 1, 4: 2}[dir];
  case 'L':
    return {1: 3, 2: 4, 3: 2, 4: 1}[dir];
  case 'B':  // 180-degree
    return {1: 2, 2: 1, 3: 4, 4: 3}[dir];
  default:
    throw new Error(`invalid turn ${turn}`);
  };
};
/**
 * Determine robot path along scaffold.
 *
 * Directions are:
 * - `1` - up (north, -Y)
 * - `2` - down (south, +Y)
 * - `3` - left (west, -X)
 * - `4` - right (east, +X)
 *
 * @param {Array} pos - initial robot [Y, X] position
 * @param {number} dir - initial robot direction
 *
 * @return {Array}
 *   Returns an array of length `count` with the FFT pattern for the given
 *   `index`.
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
    } else if (grid.getInDirection(pos, turnedDir(dir, 'B')) === 1) {
      throw new Error(`180-degree turn... does this ever happen?`);
      dir = turnedDir(turnedDir(dir, 'R'), 'R');
      path += 'R,R,';
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
  return path.slice(0, path.length-1);
};
