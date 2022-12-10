'use strict';
/** @module */
/**
 * Calculate the remainder of a
 * [modulo division](https://en.wikipedia.org/wiki/Modulo_operation).
 *
 * This version works for negative dividends.
 *
 * @param {number} n - dividend
 * @param {number} m - divisor
 *
 * @return {number}
 *   Returns the remainder of the modulo division.
 */
// h/t <https://stackoverflow.com/a/17323608/291754>
exports.mod = (n, m) => {
  return ((n % m) + m) % m;
};
/**
 * Return the unit value of an integer:
 * - if positive, return `1`
 * - if zero, return `0`
 * - if negative, return `-1`
 *
 * @param n {number} - any integer
 *
 * @return {number}
 *   Returns the unit value of the provided integer.
 */
exports.intUnit = (n) => {
  return (n === 0) ? 0 : (Math.abs(n) / n);
};
