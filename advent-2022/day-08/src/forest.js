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
  //console.log(`[${y},${x}] = ${grid[y][x]}`);
  // look from left
  let j = 0;
  for (; j < x; j++) {
    //console.log(`  [${y},${j}] = ${grid[y][j]}`);
    if (grid[y][j] >= grid[y][x]) {
      //console.log(`    TALL`);
      break;
    }
  }
  if (j === x) {
    //console.log(`    SHORT`);
    return true;
  }
  // look from right
  j = dim - 1;
  for (; j > x; j--) {
    //console.log(`  [${y},${j}] = ${grid[y][j]}`);
    if (grid[y][j] >= grid[y][x]) {
      //console.log(`    TALL`);
      break;
    }
  }
  if (j === x) {
    //console.log(`    SHORT`);
    return true;
  }
  // look from top
  j = 0;
  for (; j < y; j++) {
    //console.log(`  [${j},${x}] = ${grid[j][x]}`);
    if (grid[j][x] >= grid[y][x]) {
      //console.log(`    TALL`);
      break;
    }
  }
  if (j === y) {
    //console.log(`    SHORT`);
    return true;
  }
  // look from bottom
  j = dim - 1;
  for (; j > y; j--) {
    //console.log(`  [${j},${x}] = ${grid[j][x]}`);
    if (grid[j][x] >= grid[y][x]) {
      //console.log(`    TALL`);
      break;
    }
  }
  if (j === y) {
    //console.log(`    SHORT`);
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
  //console.log(`[${y},${x}] = ${grid[y][x]}`);
  let j;
  let dist;
  let score = 1;
  // look to left
  for (j = x - 1, dist = 0; j >= 0; j--) {
    //console.log(`  [${y},${j}] = ${grid[y][j]}`);
    dist += 1;
    if (grid[y][j] >= grid[y][x]) {
      //console.log(`    TALL`);
      break;
    }
  }
  score *= dist;
  // look to right
  for (j = x + 1, dist = 0; j < dim; j++) {
    //console.log(`  [${y},${j}] = ${grid[y][j]}`);
    dist += 1;
    if (grid[y][j] >= grid[y][x]) {
      //console.log(`    TALL`);
      break;
    }
  }
  score *= dist;
  // look to top
  for (j = y - 1, dist = 0; j >= 0; j--) {
    //console.log(`  [${j},${x}] = ${grid[j][x]}`);
    dist += 1;
    if (grid[j][x] >= grid[y][x]) {
      //console.log(`    TALL`);
      break;
    }
  }
  score *= dist;
  // look to bottom
  for (j = y + 1, dist = 0; j < dim; j++) {
    //console.log(`  [${j},${x}] = ${grid[j][x]}`);
    dist += 1;
    if (grid[j][x] >= grid[y][x]) {
      //console.log(`    TALL`);
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
