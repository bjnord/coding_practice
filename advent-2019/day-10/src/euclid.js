'use strict';
/** @module */
/**
 * Calculate the Greatest Common Divisor (GCD) of two integers using the
 * [Euclidean algorithm](https://en.wikipedia.org/wiki/Euclidean_algorithm).
 *
 * This version works for negative numbers.
 *
 * @param {number} a - first integer
 * @param {number} b - second integer
 *
 * @return {number}
 *   Returns the GCD of the two integers.
 */
// h/t <https://codereview.stackexchange.com/a/166362>
exports.gcd = (a, b) => {
  return (b === 0) ? Math.abs(a) : module.exports.gcd(Math.abs(b), Math.abs(a) % Math.abs(b));
};
