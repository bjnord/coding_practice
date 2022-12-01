'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input with sections separated by `\n\n`
 *
 * @return {Array.Array.Integer}
 *   Returns a list of elf sections, each of which is a list of item calories.
 */
exports.parse = (input) => {
  return input.trim().split(/\n\n/).map((section) => module.exports.parseSection(section));
};
/**
 * Parse one elf's section from the puzzle input.
 *
 * @param {string} section - lines of puzzle input separated by `\n`
 *
 * @return {Array.Integer}
 *   Returns a list of item calories.
 */
exports.parseSection = (section) => {
  return section.trim().split(/\n/).map((line) => parseInt(line));
};
/**
 * Calculate total calories of each elf's inventory.
 *
 * @param {Array.Array.Integer} sections - list of elf sections, each of which is a list of item calories
 *
 * @return {Array.Integer}
 *   Returns a list of total item calories for each elf section, sorted highest first.
 */
exports.totalCaloriesSorted = (sections) => {
  return sections.map((itemCalories) => {
    return itemCalories.reduce((acc, cal) => acc + cal);
  }).sort((a, b) => b - a);
};
