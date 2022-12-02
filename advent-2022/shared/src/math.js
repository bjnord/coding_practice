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
