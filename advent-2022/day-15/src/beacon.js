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

const posKey = ((pos) => '' + pos.y + ',' + pos.x);

const uniqueBeaconsOf = ((pairs) => {
  const seen = {};
  pairs.map((pair) => pair.beacon).filter((beacon) => {
    if (seen[posKey(beacon)]) {
      return false;
    } else {
      seen[posKey(beacon)] = beacon;
      return true;
    }
  });
  return Object.values(seen);
});

exports.countNotAt = ((pairs, row) => {
  const pairsCovering = module.exports.pairsCoveringRow(pairs, row);
  const rangesCovering = module.exports.columnRangesCoveringRow(pairsCovering, row);
  const ranges = module.exports.mergeRanges(rangesCovering);
  let count = 0;
  for (const range of ranges) {
    count += (range[1] - range[0] + 1);
    for (const beacon of uniqueBeaconsOf(pairsCovering)) {
      if ((beacon.y === row) && (range[0] <= beacon.x) && (beacon.x <= range[1])) {
        count--;
      }
    }
  }
  return count;
});

exports.pairsCoveringRow = ((pairs, row) => {
  return pairs.filter((pair) => {
    const y0 = pair.sensor.y - pair.range;
    const y1 = pair.sensor.y + pair.range;
    return (y0 <= row) && (row <= y1);
  });
});

exports.pairsCoveringColumn = ((pairs, col) => {
  return pairs.filter((pair) => {
    const x0 = pair.sensor.x - pair.range;
    const x1 = pair.sensor.x + pair.range;
    return (x0 <= col) && (col <= x1);
  });
});

exports.columnRangesCoveringRow = ((pairs, row) => {
  return pairs.map((pair) => {
    const dx = pair.range - Math.abs(pair.sensor.y - row);
    return [pair.sensor.x - dx, pair.sensor.x + dx];
  });
});

exports.rowRangesCoveringColumn = ((pairs, col) => {
  return pairs.map((pair) => {
    const dy = pair.range - Math.abs(pair.sensor.x - col);
    return [pair.sensor.y - dy, pair.sensor.y + dy];
  });
});

exports.clipRanges = ((ranges, limit) => {
  return ranges.map((range) => {
    return [Math.max(range[0], 0), Math.min(range[1], limit)];
  });
});

exports.rangesOverlap = ((a, b) => {
  if (a[0] > b[0]) {
    const c = a;
    a = b;
    b = c;
  }
  return b[0] <= (a[1] + 1);
});

// assumes they overlap!
exports.mergeRange = ((a, b) => {
  return [Math.min(a[0], b[0]), Math.max(a[1], b[1])];
});

exports.mergeRanges = ((ranges) => {
  const newRanges = [];
  let mergedRange = ranges.shift();
  let shrunk = false;
  for (const range of ranges) {
    if (module.exports.rangesOverlap(mergedRange, range)) {
      mergedRange = module.exports.mergeRange(mergedRange, range);
      shrunk = true;
    } else {
      newRanges.push(range);
    }
  }
  newRanges.push(mergedRange);
  if (shrunk && (newRanges.length > 1)) {
    return module.exports.mergeRanges(newRanges);
  } else {
    return newRanges;
  }
});

// returns row (`y` value) if found, or `null` if not found
exports.findBeaconAtColumn = ((pairs, col, clipAt) => {
  const pairsCovering = module.exports.pairsCoveringColumn(pairs, col);
  const rangesCovering = module.exports.clipRanges(module.exports.rowRangesCoveringColumn(pairsCovering, col), clipAt);
  const ranges = module.exports.mergeRanges(rangesCovering);
  if (ranges.length === 1) {
    return null;
  } else if (ranges.length < 1) {
    throw new SyntaxError('merged row range not found');
  } else if (ranges.length > 2) {
    throw new SyntaxError('more than 2 merged row ranges found');
  }
  if (ranges[0][0] < ranges[1][0]) {
    if ((ranges[0][1] + 2) === ranges[1][0]) {
      return ranges[0][1] + 1;
    } else {
      throw new SyntaxError(`first range end=${ranges[0][1]} second range begin=${ranges[1][0]}: not gap of 2`);
    }
  } else {
    if ((ranges[1][1] + 2) === ranges[0][0]) {
      return ranges[1][1] + 1;
    } else {
      throw new SyntaxError(`first range end=${ranges[1][1]} second range begin=${ranges[0][0]}: not gap of 2`);
    }
  }
});
