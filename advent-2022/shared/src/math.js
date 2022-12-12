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
/**
 * Compute the chessboard distance between the given positions.
 *
 * This is "the minimum number of moves needed by a king to go from
 * one square on a chessboard to another". See
 * [this article](https://en.wikipedia.org/wiki/Chebyshev_distance)
 * for more.
 *
 * @param a {Object} - 1st position (with attributes `y` and `x`)
 * @param b {Object} - 2nd position (with attributes `y` and `x`)
 *
 * @return {number}
 *   Returns the chessboard distance between the given positions.
 */
exports.chessboardDistance = ((a, b) => {
  const dy = Math.abs(a.y - b.y);
  const dx = Math.abs(a.x - b.x);
  return Math.max(dy, dx);
});
/**
 * Compute the Manhattan distance between the given positions.
 *
 * This is "the distance a car would drive to get from one intersection
 * to another". See
 * [this article](https://en.wikipedia.org/wiki/Taxicab_geometry)
 * for more.
 *
 * @param a {Object} - 1st position (with attributes `y` and `x`)
 * @param b {Object} - 2nd position (with attributes `y` and `x`)
 *
 * @return {number}
 *   Returns the Manhattan distance between the given positions.
 */
exports.manhattanDistance = ((a, b) => {
  const dy = Math.abs(a.y - b.y);
  const dx = Math.abs(a.x - b.x);
  return dy + dx;
});
