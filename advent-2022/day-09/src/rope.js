'use strict';
const math = require('../../shared/src/math');
/**
 * @module rope
 *
 * @description
 *
 * The **motion** data structure used in this module's functions is
 * an array with the following attributes:
 * - element 0: move direction (`R` `L` `D` `U`)
 * - element 1: move count (integer)
 *
 * The **position** data structure used in this module's functions is
 * an object with the following attributes:
 * - `y`: Y position (integer)
 * - `x`: X position (integer)
 */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array}
 *   Returns a list of motions.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `R 4`)
 *
 * @return {Array}
 *   Returns a motion.
 */
exports.parseLine = (line) => {
  const tokens = line.split(/\s+/);
  return [tokens[0], parseInt(tokens[1])];
};
/*
 * Turn y,x `Object` position into `string` suitable for a map key.
 */
const posKey = ((pos) => '' + pos.y + ',' + pos.x);
/**
 * Compute the chessboard distance between the given positions.
 *
 * This is "the minimum number of moves needed by a king to go from
 * one square on a chessboard to another". See
 * [this article](https://en.wikipedia.org/wiki/Chebyshev_distance)
 * for more.
 *
 * @param a {Object} - first position
 * @param b {Object} - second position
 *
 * @return {number}
 *   Returns the chessboard distance between the given positions.
 */
exports.chessDistance = ((a, b) => {
  const dy = Math.abs(a.y - b.y);
  const dx = Math.abs(a.x - b.x);
  return Math.max(dy, dx);
});
/**
 * Are the two given positions touching?
 *
 * @param a {Object} - first position
 * @param b {Object} - second position
 *
 * @return {boolean}
 *   Returns `true` if the two positions overlap (same square), or are on
 *   adjacent squares (including diagonal).
 */
exports.touching = ((a, b) => {
  return module.exports.chessDistance(a, b) <= 1;
});
/*
 * dy/dx for each type of head motion
 */
const moveDelta = {
  R: {y: 0, x: 1},
  L: {y: 0, x: -1},
  D: {y: 1, x: 0},
  U: {y: -1, x: 0},
};
/**
 * Move head knot one unit in the given direction.
 *
 * (The `pos` argument is directly updated; the function doesn't
 * return anything.)
 *
 * @param pos {Object} - position of head knot
 * @param dir {string} - direction to move (`R` `L` `D` `U`)
 */
exports.move = ((pos, dir) => {
  if (!moveDelta[dir]) {
    throw new SyntaxError(`unknown direction '${dir}'`);
  }
  pos.y += moveDelta[dir].y;
  pos.x += moveDelta[dir].x;
});
/**
 * Move tail knot one unit toward head knot, if not touching it.
 *
 * (The `tail` argument is directly updated; the function doesn't
 * return anything.)
 *
 * @param tail {Object} - position of tail knot
 * @param head {Object} - position of head knot
 */
exports.moveTail = ((tail, head) => {
  if (module.exports.touching(tail, head)) {
    return;
  }
  tail.y += math.intUnit(head.y - tail.y);
  tail.x += math.intUnit(head.x - tail.x);
});
/*
 * Dump motion section header to the console.
 */
/* istanbul ignore next */
const dumpHeader = ((motion, grid) => {
  if (!grid) {
    return;
  }
  console.log(`== ${motion[0]} ${motion[1]} ==`);
  console.log('');
});
/*
 * Render character for given grid position.
 */
/* istanbul ignore next */
const ropeChar = ((i) => (i === 0) ? 'H' : ('' + i));
/* istanbul ignore next */
const lineChar = ((rope, y, x) => {
  for (let i = 0; i < rope.length; i++) {
    if ((rope[i].y === y) && (rope[i].x === x)) {
      return ropeChar(i);
    }
  }
  return '.';
});
/*
 * Dump one line of rope depiction to the console.
 */
/* istanbul ignore next */
const dumpRopeLine = ((rope, grid, y) => {
  let line = '';
  for (let x = grid.x0; x <= grid.x1; x++) {
    line += lineChar(rope, y, x);
  }
  console.log(line);
});
/*
 * Dump visual depiction of rope to the console.
 */
/* istanbul ignore next */
const dumpRope = ((rope, grid, dumpAll) => {
  if (!grid || (grid.all !== dumpAll)) {
    return;
  }
  for (let y = grid.y0; y <= grid.y1; y++) {
    dumpRopeLine(rope, grid, y);
  }
  console.log('');
});
/*
 * Simulate one motion (N moves in a given direction).
 */
const followMotion = ((motion, rope, visited, dumpGrid) => {
  dumpHeader(motion, dumpGrid);
  for (let i = 0; i < motion[1]; i++) {
    module.exports.move(rope[0], motion[0]);
    for (let k = 1; k < rope.length; k++) {
      module.exports.moveTail(rope[k], rope[k-1]);
    }
    visited[posKey(rope[rope.length-1])] = true;
    dumpRope(rope, dumpGrid, true);
  }
  dumpRope(rope, dumpGrid, false);
});
/**
 * Simulate an n-knot rope whose head follows a list of motions.
 *
 * @param motions {Array.Array} - the list of motions
 * @param nKnots {number} - the number of knots in the rope
 * @param dumpGrid {Object} - dimensions and options for debug output
 *   (or `null` to disable)
 *
 * @return {number}
 *   Returns the number of positions the tail of the rope visited
 *   at least once.
 */
exports.followMotions = ((motions, nKnots, dumpGrid) => {
  const rope = Array(...Array(nKnots)).map(() => new Object({y: 0, x: 0}));
  const visited = {};
  motions.forEach((motion) => followMotion(motion, rope, visited, dumpGrid));
  return Object.keys(visited).length;
});
