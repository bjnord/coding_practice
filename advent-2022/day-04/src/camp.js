'use strict';
/**
 * @module camp
 *
 * @description
 *
 * The assignment pair data structure used in this module's functions is
 * a two element array, each of which is a hash representing the section
 * assignment.
 * - element 0: first elf assignment
 * - element 1: second elf assignment
 *
 * For example, the line `2-4,6-8` would be represented as:
 * ```
 *   [
 *     {min: 2, max: 4},
 *     {min: 6, max: 8},
 *   ]
 * ```
 */
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
/**
 * Is one elf's assignment fully contained by the other's?
 *
 * @param {Array.Object} pair - the assignment pair
 *
 * @return {boolean}
 *   Returns indication of whether one assignment fully contains the other.
 */
exports.fullContainment = (pair) => {  // eslint-disable-line complexity
  if ((pair[0].min >= pair[1].min) && (pair[0].max <= pair[1].max)) {
    return true;
  } else if ((pair[1].min >= pair[0].min) && (pair[1].max <= pair[0].max)) {
    return true;
  }
  return false;
};
/**
 * Does one elf's assignment overlap the other's?
 *
 * @param {Array.Object} pair - the assignment pair
 *
 * @return {boolean}
 *   Returns indication of whether one assignment overlaps the other.
 */
exports.overlap = (pair) => {
  if ((pair[0].min <= pair[1].max) && (pair[0].max >= pair[1].min)) {
    return true;
  }
  return false;
};
