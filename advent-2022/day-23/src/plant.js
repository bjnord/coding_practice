'use strict';
/** @module plant */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of [TBP].
 */
exports.parse = (input) => {
  const rows = input.trim().split(/\n/)
    .map((line) => module.exports.parseLine(line));
  const elves = [];
  let y = 0;
  for (const row of rows) {
    for (let x = 0; x < row.length; x++) {
      if (row[x]) {
        elves.push({y, x});
      }
    }
    y--;
  }
  return elves;
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `.##..`)
 *
 * @return {Array.boolean}
 *   Returns a list of pixels.
 */
exports.parseLine = (line) => {
  return line.split('').map((ch) => ch === '#');
};
