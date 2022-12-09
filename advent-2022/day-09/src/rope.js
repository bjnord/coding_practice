'use strict';
/** @module rope */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array}
 *   Returns a list of motions.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `R 4`)
 *
 * @return {Array}
 *   Returns a motion.
 */
exports.parseLine = (line) => {
  const tokens = line.split(/\s+/);
  return [tokens[0], parseInt(tokens[1])];
};
