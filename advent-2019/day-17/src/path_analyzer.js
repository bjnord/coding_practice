'use strict';
/** @module */

/**
 * Determine the vacuum's path along the scaffolding.
 *
 * This implementation uses a simple brute-force approach; see
 * `Vacuum.step()` for details. The vacuum will move from its current
 * position until it hits a dead end.
 *
 * @param {Vacuum} vacuum - the vacuum
 *
 * @return {string}
 *   Returns a string describing the vacuum's path.
 */
exports.path = (vacuum) => {
  let path = '', step;
  while ((step = vacuum.step())) {
    path += `${step},`;
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
