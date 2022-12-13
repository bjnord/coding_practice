'use strict';
/** @module signal */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of packet pairs.
 */
exports.parse = (input) => {
  return input.trim().split(/\n\n/).map((lines) => module.exports.parsePair(lines));
};
/**
 * Parse one packet pair from the puzzle input.
 *
 * @param {string} lines - two lines of puzzle input (_e.g._ `[1,2,3]\n[1,2,4]`)
 *
 * @return {Object}
 *   Returns a packet pair.
 */
exports.parsePair = (lines) => {
  let s = lines.split(/\n/);
  return {
    left: eval(s[0]),
    right: eval(s[1]),
  };
};
