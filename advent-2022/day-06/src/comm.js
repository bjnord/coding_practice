'use strict';
/** @module comm */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of [TBP].
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `...`)
 *
 * @return {Object}
 *   Returns a [TBP].
 */
exports.parseLine = (line) => {
  return null;
};

exports.firstMarker = (data) => {
  for (let i = 0; i <= data.length - 4; i++) {
    let match = true;
    for (let j = 0; j < 4; j++) {
      for (let k = 0; k < j; k++) {
        if (data.charAt(i + j) == data.charAt(i + k)) {
          match = false;
          break;
        }
      }
      if (!match) {
        break;
      }
    }
    if (match) {
      return i + 4;
    }
  }
  return null;
};
