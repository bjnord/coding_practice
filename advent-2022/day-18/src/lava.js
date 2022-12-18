'use strict';
/** @module lava */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a droplet (list of cubes).
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `2,1,5`)
 *
 * @return {Object}
 *   Returns a cube.
 */
exports.parseLine = (line) => {
  const coords = line.split(',').map((coord) => parseInt(coord));
  return {z: coords[2], y: coords[1], x: coords[0]};
};
