'use strict';
const math = require('../../shared/src/math');
/** @module rope */
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
 * Move tail knot one unit if not touching head knot.
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
/**
 * Dump visual depition of rope to the console.
 *
 * @param rope {Array.Object} - the rope (list of knots, each being a position)
 * @param grid {Object} - dimensions and options for debug output
 */
const dumpRope = ((rope, grid) => {
  for (let y = grid.y0; y <= grid.y1; y++) {
    let line = '';
    for (let x = grid.x0; x <= grid.x1; x++) {
      for (let i = 0; i < 10; i++) {
        if ((rope[i].y === y) && (rope[i].x === x)) {
          const ch = (i === 0) ? 'H' : ('' + i);
          line += ch;
          break;
        } else if (i === 9) {
          line += '.';
        }
      }
    }
    console.log(line);
  }
  console.log('');
});
/**
 * Simulate an n-knot rope whose head follows a list of motions.
 *
 * @param motions {Array.number} - the list of motions
 * @param nKnots {number} - the number of knots in the rope
 * @param dumpGrid {boolean} - dimensions and options for debug output
 *
 * @return {number}
 *   Returns the number of positions the tail of the rope visited
 *   at least once.
 */
exports.followMotions = ((motions, nKnots, dumpGrid) => {
  const rope = Array(...Array(nKnots)).map(() => new Object({y: 0, x: 0}));
  const visited = {};
  visited[posKey(rope[nKnots - 1])] = true;
  motions.forEach((motion) => {
    if (dumpGrid) {
      console.log(`== ${motion[0]} ${motion[1]} ==`);
      console.log('');
    }
    for (let i = 0; i < motion[1]; i++) {
      module.exports.move(rope[0], motion[0]);
      for (let k = 1; k < nKnots; k++) {
        module.exports.moveTail(rope[k], rope[k-1]);
      }
      visited[posKey(rope[nKnots - 1])] = true;
      if (dumpGrid && (dumpGrid.all === true)) {
        dumpRope(rope, dumpGrid);
      }
    }
    if (dumpGrid && (dumpGrid.all === false)) {
      dumpRope(rope, dumpGrid);
    }
  });
  return Object.keys(visited).length;
});
