'use strict';
const math = require('../../shared/src/math');
/** @module beacon */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of pairs.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `Sensor at x=2, y=18: closest beacon is at x=-2, y=15`)
 *
 * @return {Object}
 *   Returns a pair.
 */
exports.parseLine = (line) => {
  const m = line.match(/Sensor\s+at\s+x=([\d-]+),\s+y=([\d-]+):\s+closest\s+beacon\s+is\s+at\s+x=([\d-]+),\s+y=([\d-]+)/);
  const pair = {
    sensor: {y: parseInt(m[2]), x: parseInt(m[1])},
    beacon: {y: parseInt(m[4]), x: parseInt(m[3])},
  };
  pair.range = math.manhattanDistance(pair.sensor, pair.beacon);
  return pair;
};

exports.notAt = ((pair, row) => {
  const dx = pair.range - Math.abs(pair.sensor.y - row);
  const points = [];
  for (let i = -dx; i <= dx; i++) {
    points.push({y: row, x: pair.sensor.x + i});
  }
  return points;
});

const posKey = ((pos) => '' + pos.y + ',' + pos.x);

exports.countNotAt = ((pairs, row) => {
  const grid = {};
  for (const pair of pairs) {
    const points = module.exports.notAt(pair, row);
    for (const point of points) {
      grid[posKey(point)] = true;
    }
  }
  for (const pair of pairs) {
    if (pair.beacon.y === row) {
      delete grid[posKey(pair.beacon)];
    }
  }
  return Object.keys(grid).length;
});
