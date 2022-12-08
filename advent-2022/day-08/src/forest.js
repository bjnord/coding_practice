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
