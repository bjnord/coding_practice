'use strict';
/** @module beacon */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of pairs.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `Sensor at x=2, y=18: closest beacon is at x=-2, y=15`)
 *
 * @return {Object}
 *   Returns a pair.
 */
exports.parseLine = (line) => {
  const m = line.match(/Sensor\s+at\s+x=([\d-]+),\s+y=([\d-]+):\s+closest\s+beacon\s+is\s+at\s+x=([\d-]+),\s+y=([\d-]+)/);
  return {
    sensor: {y: parseInt(m[2]), x: parseInt(m[1])},
    beacon: {y: parseInt(m[4]), x: parseInt(m[3])},
  };
};
