'use strict';
/** @module util */
/**
 * Find the common keys of two hashes.
 *
 * @param {Object} a - first hash
 * @param {Object} b - second hash
 *
 * @return {Array}
 *   Returns a list of keys common to the provided hashes.
 */
exports.commonKeys2 = (a, b) => {
  const keys = [];
  for (const k in a) {
    if (b[k]) {
      keys.push(k);
    }
  }
  return keys;
};
/**
 * Find the common keys of a list of hashes.
 *
 * @param {...Object} hashes - list of hashes
 *
 * @return {Array}
 *   Returns a list of keys common to the provided hashes.
 */
exports.commonKeys = (...hashes) => {
  if (hashes.length < 2) {
    throw new SyntaxError('must provide at least 2 hashes');
  }
  let h = hashes.shift();
  for (const h1 of hashes) {
    const keys = module.exports.commonKeys2(h, h1);
    h = keys.reduce((newH, k) => (newH[k] = true, newH), {});
  }
  return Object.keys(h);
};
