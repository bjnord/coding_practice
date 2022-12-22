'use strict';
const BoardMap = require('../src/board_map');
const BoardMapWalker = require('../src/board_map_walker');
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
  // important not to `trim()` here (need leading spaces)
  const sections = input.split(/\n\n/);
  return {
    map: new BoardMap(sections[0]),
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
/**
 * Follow the steps in a set of notes.
 *
 * @param {Object} notes - the set of notes
 */
exports.followNotes = ((notes) => {
  notes.walker = new BoardMapWalker(notes.map);
  for (const step of notes.steps) {
    if (step.turn) {
      notes.walker.turn(step.turn);
    } else {
      notes.walker.move(step.move);
    }
  }
});
/**
 * Calculate the password for a set of notes.
 *
 * @param {Object} notes - the set of notes
 *
 * @return {number}
 *   Returns the password for a set of notes.
 */
exports.password = ((notes) => {
  // "Rows start from 1 at the top and count downward; columns start
  // from 1 at the left and count rightward."
  const row = notes.walker.position().y + 1;
  const col = notes.walker.position().x + 1;
  // "The final password is the sum of 1000 times the row,
  // 4 times the column, and the facing."
  return 1000 * row + 4 * col + notes.walker.facing();
});
