'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of roshambo rounds.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `A Y`)
 *
 * @return {Object}
 *   Returns a roshambo round.
 */
exports.parseLine = (line) => {
  const moves = line.trim().split(/\s/);
  return {opponent: moves[0], player: moves[1]};
};
