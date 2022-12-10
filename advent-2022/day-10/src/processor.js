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
  if (inst.op === 'addx') {
    inst.arg = parseInt(tokens[1]);
  }
  return inst;
};

exports.signalStrengths = ((program) => {
  let cycle = 1;
  let x = 1;
  const ss = [];
  for (const inst of program) {
    if (inst.op === 'addx') {
      if (((cycle + 20) % 40) === 0) {
        // now "during" the first of two cycles needed for `addx`
        ss.push(cycle * x);
      }
      cycle++;
      if (((cycle + 20) % 40) === 0) {
        // now "during" the second of two cycles needed for `addx`
        ss.push(cycle * x);
      }
      // now "after" the two cycles needed for `addx`
      x += inst.arg;
    } else {  // noop
      if (((cycle + 20) % 40) === 0) {
        // "during" the lone cycle needed for `noop`
        ss.push(cycle * x);
      }
    }
    cycle++;
    if (ss.length >= 6) {
      break;
    }
  }
  return ss;
});
