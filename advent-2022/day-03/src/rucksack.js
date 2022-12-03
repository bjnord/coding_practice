'use strict';
/**
 * @module rucksack
 *
 * @description
 *
 * The rucksack data structure used in this module's functions is a three
 * element array, each of which is a hash whose keys are the item types.
 * - element 0: first compartment
 * - element 1: second compartment
 * - element 2: both compartments
 *
 * For example, the line `PmmdPrvPwwTg` (having the two halves `PmmdPr` and
 * `vPwwTg`) would be represented as:
 * ```
 *   [
 *     { 'P': true, 'd': true, 'm': true, 'r': true, },
 *     { 'P': true, 'T': true, 'g': true, 'v': true, 'w': true, },
 *     { 'P': true, 'T': true, 'd': true, 'g': true,
 *       'm': true, 'r': true, 'v': true, 'w': true, },
 *   ]
 * ```
 */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.Object}
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
 * @return {Array.Object}
 *   Returns a rucksack.
 */
exports.parseLine = (line) => {
  const len = line.length;
  if ((len % 2) === 1) {
    throw new SyntaxError('invalid odd-sized line');
  }
  return [
    itemsToHash(line.substring(0, len/2)),
    itemsToHash(line.substring(len/2, len)),
    itemsToHash(line),
  ];
};

exports.commonItem = (ruck) => {
  for (const ch in ruck[0]) {
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

exports.commonItems3 = (rucksacks) => {
  const commons = [];
  for (let i = 0; i < rucksacks.length; i = i + 3) {
    let common = null;
    for (const ch in rucksacks[i+0][2]) {
      if (rucksacks[i+1][2][ch] && rucksacks[i+2][2][ch]) {
        common = ch;
        break;
      }
    }
    commons.push(common);
  }
  return commons;
};
