'use strict';
/** @module forest */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.number}
 *   Returns a two-dimensional array of tree heights (integers).
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => {
    return line.split('').map((ch) => parseInt(ch));
  });
};
