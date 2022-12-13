'use strict';
/** @module signal */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of packet pairs.
 */
exports.parse = (input) => {
  return input.trim().split(/\n\n/).map((lines) => module.exports.parsePair(lines));
};
/**
 * Parse one packet pair from the puzzle input.
 *
 * @param {string} lines - two lines of puzzle input (_e.g._ `[1,2,3]\n[1,2,4]`)
 *
 * @return {Object}
 *   Returns a packet pair.
 */
exports.parsePair = (lines) => {
  const s = lines.split(/\n/);
  return {
    left: eval(s[0]),
    right: eval(s[1]),
  };
};

const compareLists = ((a, b) => {
  for (let i = 0; i < a.length; i++) {
    if (b[i] === undefined) {
      // right side smaller = NOT correct order
      return 1;
    }
    const c = module.exports.compare(a[i], b[i]);
    if (c !== 0) {
      return c;
    }
  }
  if (b.length > a.length) {
    // left side smaller = correct order
    return -1;
  }
  return 0;
});

exports.compare = ((a, b) => {
  if (Array.isArray(a)) {
    if (Array.isArray(b)) {
      return compareLists(a, b);
    } else {
      return compareLists(a, [b]);
    }
  } else if (Array.isArray(b)) {
    return compareLists([a], b);
  } else {
    return (a < b) ? -1 : ((a > b) ? 1 : 0);
  }
});

exports.comparePairs = ((pairs) => {
  return pairs.map((pair) => module.exports.compare(pair.left, pair.right));
});
