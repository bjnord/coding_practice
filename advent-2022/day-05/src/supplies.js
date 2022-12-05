'use strict';
/** @module supplies */
/**
 * Parse the crates section of the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.number}
 *   Returns a list of stacks of crates.
 */
exports.parseCrates = (input) => {
  const cratesInput = input.split(/\n\n/)[0];
  const stacks = [];
  cratesInput.split(/\n/)
    .filter((line) => line.includes('['))
    .forEach((line) => {
      const nstacks = (line.length + 1) / 4;
      for (let i = 0; i < nstacks; i++) {
        const ch = line.substring(i*4+1, i*4+2);
        if (ch !== ' ') {
          if (!stacks[i]) {
            stacks[i] = [ch];
          } else {
            stacks[i].unshift(ch);
          }
        }
      }
    });
  return stacks;
};
/**
 * Parse the procedure section of the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.number}
 *   Returns a list of procedure steps.
 */
exports.parseSteps = (input) => {
  const stepsInput = input.trim().split(/\n\n/)[1];
  return stepsInput.split(/\n/)
    .map((line) => line.trim().split(/\s+/))
    .map((tokens) => {
      return [
        parseInt(tokens[1]),
        parseInt(tokens[3]),
        parseInt(tokens[5]),
      ];
    });
};
