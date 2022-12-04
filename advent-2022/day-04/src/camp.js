'use strict';
/** @module camp */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.Object}
 *   Returns a list of assignment pairs.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `2-4,6-8`)
 *
 * @return {Array.Object}
 *   Returns an assignment pair.
 */
exports.parseLine = (line) => {
  return line.split(',').map((range) => {
    const minMax = range.split('-').map((n) => parseInt(n));
    return {min: minMax[0], max: minMax[1]};
  });
};
