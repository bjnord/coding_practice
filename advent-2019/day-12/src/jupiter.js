'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input (e.g. `<x=-6, y=-5, z=-8>`)
 *
 * @return {Array}
 *   Returns a list of moons, each one an object with these fields:
 *   - `pos` - position of moon (`[Z, Y, X]` coordinates)
 *   - `vel` - velocity of moon (`[dZ, dY, dX]` vector)
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => ({pos: module.exports.parseLine(line), vel: [0, 0, 0]}));
};
/**
 * Parse one line of coordinates from the puzzle input.
 *
 * @param {string} line - line of puzzle input (e.g. `<x=-6, y=-5, z=-8>`)
 *
 * @return {Array}
 *   Returns a [Z, Y, X] coordinates tuple.
 */
exports.parseLine = (line) => {
  const c = line.trim().split(/=/).map((c) => parseInt(c));
  return [c[3], c[2], c[1]];
};
