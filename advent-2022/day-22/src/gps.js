'use strict';
/** @module gps */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input with sections separated by `\n\n`
 *
 * @return {Object}
 *   Returns a set of notes.
 */
exports.parse = (input) => {
  const sections = input.trim().split(/\n\n/);
  return {
    steps: module.exports.parseSteps(sections[1]),
  };
};
/**
 * Parse the steps line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `10R5L5R10L4R5L5`)
 *
 * @return {Array.Object}
 *   Returns a list of steps.
 */
exports.parseSteps = (line) => {
  return line.trim().concat('\n').split('').reduce((state, ch) => {
    if (ch === '\n') {
      state.steps.push({move: state.n});
      state.n = 0;
    } else if ((ch >= '0') && (ch <= '9')) {
      state.n = state.n * 10 + (ch - '0');
    } else {
      state.steps.push({move: state.n});
      state.n = 0;
      state.steps.push({turn: (ch === 'L') ? -90 : 90});
    }
    return state;
  }, {steps: [], n: 0}).steps;
};
