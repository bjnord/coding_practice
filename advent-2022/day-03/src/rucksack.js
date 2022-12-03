'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of rucksacks.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input
 *
 * @return {Object}
 *   Returns a rucksack.
 */
exports.parseLine = (line) => {
  const len = line.length;
  if ((len % 2) === 1) {
    throw 'invalid odd-sized line';
  }
  return [line.substring(0, len/2), line.substring(len/2, len)];
};
