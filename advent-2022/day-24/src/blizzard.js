'use strict';
/** @module blizzard */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of [TBP].
 */
exports.parse = (input) => {
  let height = 0, width, startX, endX, blizzards = [];
  for (const line of input.trim().split(/\n/)) {
    if (endX !== undefined) {
      throw new SyntaxError('floor after end');
    }
    width = line.length;
    const door = _parseEdgeLine(line);
    if (door !== undefined) {
      if (height === 0) {
        startX = door;
      } else {
        endX = door;
      }
    } else {
      if (height === 0) {
        throw new SyntaxError('floor before start');
      }
      blizzards = blizzards.concat(_parseLine(line, height));
    }
    height += 1;
  }
  if (endX === undefined) {
    throw new SyntaxError('end not found');
  }
  return {height, width, startX, endX, blizzards};
};
/*
 * Translate line character to blizzard direction.
 */
const _blizzardDir = ((ch) => {
  const chars = '^>v<';
  const dirs = [
    {y: 1, x: 0},
    {y: 0, x: 1},
    {y: -1, x: 0},
    {y: 0, x: -1},
  ];
  return dirs[chars.indexOf(ch)];
});
/*
 * Translate line characters to blizzards.
 */
const _parseLine = ((line, y) => {
  const lineBlizzards = [];
  line.split('').forEach((ch, x) => {
    const dir = _blizzardDir(ch);
    if (dir) {
      lineBlizzards.push({y, x, dir});
    } else if ((ch !== '#') && (ch !== '.')) {
      throw new SyntaxError(`unknown cell '${ch}' at ${y},${x}`);
    }
  });
  return lineBlizzards;
});
/*
 * Is this a start/end row?
 */
const _isStartEnd = ((line) => {
  return (line.substring(0, 2) === '##')
    || (line.substring(line.length - 2) === '##');
});
/*
 * Parse start/end row, returning X position of door (or `undefined`).
 */
const _parseEdgeLine = ((line) => {
  if (_isStartEnd(line)) {
    const door = line.indexOf('.');
    if (door < 0) {
      throw new SyntaxError('top/bottom line with no door');
    }
    return door;
  } else {
    return undefined;
  }
});
