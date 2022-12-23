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
exports.parse = (input, debug) => {
  // important not to `trim()` here (need leading spaces)
  const sections = input.split(/\n\n/);
  return {
    map: new BoardMap(sections[0], debug),
    steps: module.exports.parseSteps(sections[1]),
  };
};
/*
 * Parser state: Return initial state.
 */
const _initialState = (() => {
  return {steps: [], n: 0};
});
/*
 * Parser state: Accumuluate digit to value.
 */
const _accumulateDigit = ((state, ch) => {
  state.n = state.n * 10 + (ch - '0');
});
/*
 * Parser state: Push accumulated value as a "move" step.
 */
const _pushMove = ((state) => {
  state.steps.push({move: state.n});
  state.n = 0;
});
/*
 * Parser state: Push character as a "turn" step.
 */
const _pushTurn = ((state, ch) => {
  state.steps.push({turn: (ch === 'L') ? -90 : 90});
});
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
      _pushMove(state);
    } else if ((ch >= '0') && (ch <= '9')) {
      _accumulateDigit(state, ch);
    } else {
      _pushMove(state);
      _pushTurn(state, ch);
    }
    return state;
  }, _initialState()).steps;
};
/**
 * Follow the steps in a set of notes.
 *
 * @param {Object} notes - the set of notes
 * @param {boolean} cubic - treat the board map as a cube?
 */
exports.followNotes = ((notes, cubic, debug) => {
  notes.walker = new BoardMapWalker(notes.map, cubic, debug);
  for (const step of notes.steps) {
    if (step.turn) {
      notes.walker.turn(step.turn);
      /* istanbul ignore next */
      if (debug) {
        const pos = notes.walker.position();
        const dir = notes.walker.direction();
        console.debug(`=== after turn ${step.turn}: pos ${pos.y},${pos.x} dir ${dir}`);
      }
    } else {
      notes.walker.move(step.move);
      /* istanbul ignore next */
      if (debug) {
        const pos = notes.walker.position();
        const dir = notes.walker.direction();
        console.debug(`=== after move ${step.move}: pos ${pos.y},${pos.x} dir ${dir}`);
      }
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
  return 1000 * row + 4 * col + notes.walker.facingValue();
});
/**
 * Produce the trail map for a set of notes.
 *
 * @param {Object} notes - the set of notes
 *
 * @return {string}
 *   Returns a map render (lines separated by `\n`) with the trail marked.
 */
exports.renderTrail = ((notes) => {
  return notes.walker.renderTrail(notes);
});
