'use strict';
/** @module hill */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Object}
 *   Returns the height map.
 */
exports.parse = (input) => {
  const rows = input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
  const startRowI = rows.findIndex((row) => 'start' in row);
  const endRowI = rows.findIndex((row) => 'end' in row);
  return {
    height: rows.length,
    width: rows[0].heights.length,
    start: [startRowI, rows[startRowI].start],
    end: [endRowI, rows[endRowI].end],
    rows
  };
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `Sabqponm`)
 *
 * @return {Array.number}
 *   Returns the corresponding row of the height map.
 */
exports.parseLine = (line) => {
  const h = {heights: []};
  for (let i = 0; i < line.length; i++) {
    let cc = line.charCodeAt(i);
    if (cc === 83) {  // S
      h.start = i;
      cc = 97;  // a (1)
    } else if (cc === 69) {  // E
      h.end = i;
      cc = 122;  // z (26)
    }
    h.heights.push(cc - 96);
  }
  return h;
};

exports.neighbors = ((grid, pos) => {
  const deltas = [[-1, 0], [1, 0], [0, -1], [0, 1]];
  const neighbors = [];
  for (const delta of deltas) {
    const nPos = [pos[0], pos[1]];
    nPos[0] += delta[0];
    nPos[1] += delta[1];
    if ((nPos[0] >= 0) && (nPos[0] < grid.height)) {
      if ((nPos[1] >= 0) && (nPos[1] < grid.width)) {
        neighbors.push(nPos);
      }
    }
  }
  return neighbors;
});
