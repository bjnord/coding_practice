'use strict';
/** @module hill */
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
  const h = {heights: []};
  for (let i = 0; i < line.length; i++) {
    let cc = line.charCodeAt(i);
    if (cc === 83) {  // S
      h.start = i;
      cc = 97;  // a (1)
    } else if (cc === 69) {  // E
      h.end = i;
      cc = 122;  // z (26)
    }
    h.heights.push(cc - 96);
  }
  return h;
};
