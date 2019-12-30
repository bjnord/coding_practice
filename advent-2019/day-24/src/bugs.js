'use strict';
/** @module */

/**
 * Parse a grid state.
 *
 * @param {Array} lines - list of grid lines
 *
 * @return {number}
 *   Returns the parsed grid state.
 */
exports.parse = (lines) => {
  let state = 0b0;
  for (let y = 0, bit = 0b1; y < 5; y++) {
    for (let x = 0; x < 5; x++, bit *= 2) {
      const pixel = (lines[y][x] === '#') ? 0b1 : ((lines[y][x] === '.') ? 0b0 : NaN);
      if (isNaN(pixel)) {  // invalid character
        return NaN;
      }
      state |= bit * pixel;
    }
  }
  return state;
};
// private: is there a bug at the given position?
const _isBugAt = (state, pos) => {
  const y = pos[0];
  const x = pos[1];
  if ((y >= 0) && (y < 5) && (x >= 0) && (x < 5)) {
    const i = y * 5 + x;
    const bit = Math.pow(2, i);
    return (state & bit) ? true : false;
  } else {
    return false;
  }
};
/**
 * Format a grid state.
 *
 * @param {number} state - the grid state
 *
 * @return {Array}
 *   Returns a list of grid lines (strings).
 */
exports.format = (state) => {
  const lines = [];
  for (let y = 0, s = '', bit = 0b1; y < 5; y++, s = '') {
    for (let x = 0; x < 5; x++, bit *= 2) {
      s += _isBugAt(state, [y, x]) ? '#' : '.';
    }
    lines.push(s);
  }
  return lines;
};
/**
 * Count adjacent bugs at a grid position.
 *
 * @param {number} state - the grid state
 * @param {Array} pos - the [Y, X] position
 *
 * @return {number}
 *   Returns the number of adjacent bugs.
 */
exports.countAdjacent = (state, pos) => {
  const dirs = [
    [-1, 0],  // up
    [1, 0],   // down
    [0, -1],  // left
    [0, 1],   // right
  ];
  return dirs.map((dir) => {
    const y = pos[0] + dir[0];
    const x = pos[1] + dir[1];
    return _isBugAt(state, [y, x]) ? 1 : 0;
  }).reduce((sum, b) => sum + b, 0);
};
/**
 * Determine next event at a grid position.
 *
 * @param {number} state - the grid state
 * @param {Array} pos - the [Y, X] position
 *
 * @return {string}
 *   Returns one of `death`, `spawn`, `stasis`.
 */
exports.event = (state, pos) => {
  const isBug = _isBugAt(state, pos);
  const count = module.exports.countAdjacent(state, pos);
  //console.debug(`pos ${pos} bug? ${isBug} count ${count}`);
  /*
   * "A bug dies (becoming an empty space) unless there is exactly one bug
   *   adjacent to it."
   * "An empty space becomes infested with a bug if exactly one or two bugs
   *   are adjacent to it."
   * "Otherwise, a bug or empty space remains the same."
   */
  switch (count) {
  case 0:
    return isBug ? 'death'  : 'stasis';
  case 1:
    return isBug ? 'stasis' : 'spawn';
  case 2:
    return isBug ? 'death'  : 'spawn';
  default:  // 3, 4
    return isBug ? 'death'  : 'stasis';
  }
};
/**
 * Generate next state from current state.
 *
 * @param {number} currentState - the grid state for the current generation
 *
 * @return {number}
 *   Returns the grid state for the next generation.
 */
exports.generate = (currentState) => {
  let state = 0b0;
  for (let y = 0, bit = 0b1; y < 5; y++) {
    for (let x = 0; x < 5; x++, bit *= 2) {
      const event = module.exports.event(currentState, [y, x]);
      //console.debug(`pos ${[y, x]} event ${event}`);
      switch (event) {
      case 'death':
        state &= ~bit;
        break;
      case 'spawn':
        state |= bit;
        break;
      case 'stasis':
        state |= (currentState & bit);
        break;
      }
    }
  }
  return state;
};
/**
 * Iterate generations until a repeat is found.
 *
 * @param {number} state - the grid state for the starting generation
 *
 * @return {number}
 *   Returns the first grid state that we have seen before.
 */
exports.iterate = (state) => {
  for (const sawState = {}; !sawState[state]; state = module.exports.generate(state)) {
    sawState[state] = true;
  }
  return state;
};
