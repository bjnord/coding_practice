'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input with sections separated by `\n\n`
 *
 * @return {Array}
 *   Returns a list of elf sections, each of which is a list of item calories (Integer).
 */
exports.parse = (input) => {
  return input.trim().split(/\n\n/).map((section) => module.exports.parseSection(section));
};
/**
 * Parse one elf's section from the puzzle input.
 *
 * @param {string} line - lines of puzzle input separated by '\n'
 *
 * @return {Array}
 *   Returns a list of item calories (Integer).
 */
exports.parseSection = (section) => {
  return section.trim().split(/\n/).map((line) => parseInt(line));
};
