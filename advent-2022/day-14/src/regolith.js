'use strict';
/** @module regolith */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.Object}
 *   Returns a list of paths.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `498,4 -> 498,6 -> 496,6`)
 *
 * @return {Array.Object}
 *   Returns a path.
 */
exports.parseLine = (line) => {
  return line.split(/\s+->\s+/).map((posStr) => {
    const coords = posStr.split(/,/)
      .map((coordStr) => parseInt(coordStr));
    return {y: coords[1], x: coords[0]};
  });
};

const posKey = ((pos) => '' + pos.y + ',' + pos.x);

const rockLine = ((grid, from, to) => {
  if (from.y === to.y) {
    const x0 = Math.min(from.x, to.x);
    const x1 = Math.max(from.x, to.x);
    for (let x = x0; x <= x1; x++) {
      const pt = {y: from.y, x};
      grid[posKey(pt)] = 1;
    }
  } else if (from.x === to.x) {
    const y0 = Math.min(from.y, to.y);
    const y1 = Math.max(from.y, to.y);
    for (let y = y0; y <= y1; y++) {
      const pt = {y, x: from.x};
      grid[posKey(pt)] = 1;
    }
  } else {
    throw new SyntaxError('path not in a straight line');
  }
  return Math.max(from.y, to.y);
});

exports.makeMap = ((paths) => {
  const grid = {};
  let maxY = -Number.MAX_SAFE_INTEGER;
  for (const path of paths) {
    let from = path.shift();
    while (path.length > 0) {
      const to = path.shift();
      const maxY0 = rockLine(grid, from, to);
      maxY = Math.max(maxY, maxY0);
      from = to;
    }
  }
  return {grid, maxY};
});

exports.dropSand = ((map) => {
  let pos = {y: 0, x: 500};
  if (map.grid[posKey(pos)]) {
    // no more room for incoming sand
    return false;
  }
  for (;;) {
    if (pos.y > map.maxY) {
      // falls into endless void
      return false;
    } else if (!map.grid[posKey({y: pos.y + 1, x: pos.x})]) {
      // falls straight down
      pos = {y: pos.y + 1, x: pos.x};
    } else if (!map.grid[posKey({y: pos.y + 1, x: pos.x - 1})]) {
      // falls down & left
      pos = {y: pos.y + 1, x: pos.x - 1};
    } else if (!map.grid[posKey({y: pos.y + 1, x: pos.x + 1})]) {
      // falls down & right
      pos = {y: pos.y + 1, x: pos.x + 1};
    } else {
      // came to rest w/sand below
      map.grid[posKey(pos)] = 2;
      return true;
    }
    if (map.floorY && ((pos.y + 1) === map.floorY)) {
      // came to rest w/floor below
      map.grid[posKey(pos)] = 2;
      return true;
    }
  }
});

exports.totalSand = ((map) => {
  for (let i = 0; ; i++) {
    if (!module.exports.dropSand(map)) {
      return i;
    }
  }
});
