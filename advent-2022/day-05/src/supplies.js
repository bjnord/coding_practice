'use strict';
/** @module supplies */
/**
 * Parse the crates section of the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.number}
 *   Returns a list of stacks of crates.
 */
exports.parseCrates = (input) => {
  const cratesInput = input.split(/\n\n/)[0];
  const stacks = [];
  cratesInput.split(/\n/)
    .filter((line) => line.includes('['))
    .forEach((line) => {
      const nstacks = (line.length + 1) / 4;
      for (let i = 0; i < nstacks; i++) {
        const ch = line.substring(i*4+1, i*4+2);
        if (ch !== ' ') {
          if (!stacks[i]) {
            stacks[i] = [ch];
          } else {
            stacks[i].unshift(ch);
          }
        }
      }
    });
  return stacks;
};
/**
 * Parse the procedure section of the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.number}
 *   Returns a list of procedure steps.
 */
exports.parseSteps = (input) => {
  const stepsInput = input.trim().split(/\n\n/)[1];
  return stepsInput.split(/\n/)
    .map((line) => line.trim().split(/\s+/))
    .map((tokens) => {
      return [
        parseInt(tokens[1]),
        parseInt(tokens[3]),
        parseInt(tokens[5]),
      ];
    });
};

// TODO detect empty stack
const moveCrate = (crates, from, to) => {
  const crate = crates[from].pop();
  crates[to].push(crate);
};

const topCrates = (crates) => {
  return crates.map((stack) => stack[stack.length - 1]).join('');
};

exports.moveCrates = (crates, steps) => {
  for (const step of steps) {
    for (let i = 0; i < step[0]; i++) {  // # crates to move
      moveCrate(crates, step[1] - 1, step[2] - 1);
    }
  }
  return topCrates(crates);
};

// TODO detect empty stack
const moveCrateGroup = (crates, n, from, to) => {
  const temp = [];
  for (let i = 0; i < n; i++) {
    const crate = crates[from].pop();
    temp.push(crate);
  }
  for (let i = 0; i < n; i++) {
    const crate = temp.pop();
    crates[to].push(crate);
  }
};

exports.multiMoveCrates = (crates, steps) => {
  for (const step of steps) {
    moveCrateGroup(crates, step[0], step[1] - 1, step[2] - 1);
  }
  return topCrates(crates);
};
