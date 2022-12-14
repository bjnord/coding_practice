'use strict';
/** @module regolith */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.Object}
 *   Returns a list of paths.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `498,4 -> 498,6 -> 496,6`)
 *
 * @return {Array.Object}
 *   Returns a path.
 */
exports.parseLine = (line) => {
  return line.split(/\s+->\s+/).map((posStr) => {
    const coords = posStr.split(/,/)
      .map((coordStr) => parseInt(coordStr));
    return {y: coords[1], x: coords[0]};
  });
};
