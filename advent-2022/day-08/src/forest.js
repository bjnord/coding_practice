'use strict';
/** @module forest */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.number}
 *   Returns a two-dimensional array of tree heights (integers).
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => {
    return line.split('').map((ch) => parseInt(ch));
  });
};

exports.isVisible = (grid, y, x) => {
  const dim = grid[0].length;
  // edge trees are always visible
  if ((y <= 0) || (y >= dim - 1)) {
    return true;
  } else if ((x <= 0) || (x >= dim - 1)) {
    return true;
  }
  // consider tree at [y, x]
  // look from left
  let j = 0;
  for (; j < x; j++) {
    if (grid[y][j] >= grid[y][x]) {
      break;
    }
  }
  if (j === x) {
    return true;
  }
  // look from right
  j = dim - 1;
  for (; j > x; j--) {
    if (grid[y][j] >= grid[y][x]) {
      break;
    }
  }
  if (j === x) {
    return true;
  }
  // look from top
  j = 0;
  for (; j < y; j++) {
    if (grid[j][x] >= grid[y][x]) {
      break;
    }
  }
  if (j === y) {
    return true;
  }
  // look from bottom
  j = dim - 1;
  for (; j > y; j--) {
    if (grid[j][x] >= grid[y][x]) {
      break;
    }
  }
  if (j === y) {
    return true;
  }
  return false;
};

exports.nVisible = (grid) => {
  const dim = grid[0].length;
  let total = 0;
  for (let y = 0; y < dim; y++) {
    for (let x = 0; x < dim; x++) {
      total += module.exports.isVisible(grid, y, x) ? 1 : 0;
    }
  }
  return total;
};

exports.scenicScore = (grid, y, x) => {
  const dim = grid[0].length;
  // "If a tree is right on the edge, at least one of its viewing distances will be zero."
  if ((y <= 0) || (y >= dim - 1)) {
    return 0;
  } else if ((x <= 0) || (x >= dim - 1)) {
    return 0;
  }
  // consider tree at [y, x]
  let j;
  let dist;
  let score = 1;
  // look to left
  for (j = x - 1, dist = 0; j >= 0; j--) {
    dist += 1;
    if (grid[y][j] >= grid[y][x]) {
      break;
    }
  }
  score *= dist;
  // look to right
  for (j = x + 1, dist = 0; j < dim; j++) {
    dist += 1;
    if (grid[y][j] >= grid[y][x]) {
      break;
    }
  }
  score *= dist;
  // look to top
  for (j = y - 1, dist = 0; j >= 0; j--) {
    dist += 1;
    if (grid[j][x] >= grid[y][x]) {
      break;
    }
  }
  score *= dist;
  // look to bottom
  for (j = y + 1, dist = 0; j < dim; j++) {
    dist += 1;
    if (grid[j][x] >= grid[y][x]) {
      break;
    }
  }
  score *= dist;
  return score;
};

exports.maxScenicScore = (grid) => {
  const dim = grid[0].length;
  let max = 0;
  for (let y = 0; y < dim; y++) {
    for (let x = 0; x < dim; x++) {
      const ss = module.exports.scenicScore(grid, y, x);
      if (ss > max) {
        max = ss;
      }
    }
  }
  return max;
};
