'use strict';
/** @module processor */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of instructions.
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
 *   Returns an instruction.
 */
exports.parseLine = (line) => {
  const tokens = line.split(/\s+/);
  const inst = {op: tokens[0]};
  if (inst.op == 'addx') {
    inst.arg = parseInt(tokens[1]);
  }
  return inst;
};
