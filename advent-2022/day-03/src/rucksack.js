'use strict';
const util = require('../../shared/src/util');
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
 * Convert a string of item characters into hash.
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
/**
 * Find the common item between two rucksack compartments.
 *
 * @param {Array.Object} ruck - the rucksack
 *
 * @return {string}
 *   Returns the item found in both compartments of the rucksack.
 * @throws {SyntaxError}
 *   Throws an error if no common item is found, or if multiple common items
 *   are.
 */
exports.commonItem = (ruck) => {
  const items = util.commonKeys(...ruck);
  if (items.length === 0) {
    throw new SyntaxError('no common item found');
  } else if (items.length === 1) {
    return items[0];
  } else {
    throw new SyntaxError('multiple common items found');
  }
};
/**
 * Calculate the priority of an item.
 *
 * - Lowercase item types a through z have priorities 1 through 26.
 * - Uppercase item types A through Z have priorities 27 through 52.
 *
 * @param {string} ch - the item
 *
 * @returns {number}
 *   Returns the priority of the item.
 */
exports.itemPriority = (ch) => {
  const code = ch.charCodeAt(0);
  if (code >= 97) {
    return code - 96;
  } else {
    return code - 64 + 26;
  }
};
/**
 * Find the common item between every three rucksacks.
 *
 * @param {Array.Array.Object} rucksacks - the rucksacks
 *
 * @return {Array.string}
 *   Returns a list of the item found in each group of three rucksacks.
 * @throws {SyntaxError}
 *   Throws an error if, for any group of three rucksacks, no common item
 *   is found, or if multiple common items are.
 */
exports.commonItems3 = (rucksacks) => {
  const commons = [];
  // TODO is there a JS equivalent of Elixir's `take`?
  //      if not, would a custom iterator be cleaner?
  for (let i = 0; i < rucksacks.length; i = i + 3) {
    const items = util.commonKeys(rucksacks[i+0][2], rucksacks[i+1][2], rucksacks[i+2][2]);
    if (items.length === 0) {
      throw new SyntaxError('no common item found');
    } else if (items.length === 1) {
      commons.push(items[0]);
    } else {
      throw new SyntaxError('multiple common items found');
    }
  }
  return commons;
};
