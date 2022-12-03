'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of rucksacks.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/*
 * Convert string of item characters into hash.
 */
const itemsToHash = (items) => {
  return items.split('').reduce((h, ch) => {
    h[ch] = true;
    return h;
  }, {});
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input
 *
 * @return {Object}
 *   Returns a rucksack.
 */
exports.parseLine = (line) => {
  const len = line.length;
  if ((len % 2) === 1) {
    throw 'invalid odd-sized line';
  }
  return [
    itemsToHash(line.substring(0, len/2)),
    itemsToHash(line.substring(len/2, len)),
  ];
};

exports.commonItem = (ruck) => {
  for (let ch in ruck[0]) {
    if (ruck[1][ch]) {
      return ch;
    }
  }
  return null;
};

exports.itemPriority = (ch) => {
  const code = ch.charCodeAt(0);
  if (code >= 97) {
    return code - 96;
  } else {
    return code - 64 + 26;
  }
};
