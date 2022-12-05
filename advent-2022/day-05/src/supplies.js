'use strict';
/** @module supplies */
/**
 * Parse the stacks section of the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.number}
 *   Returns a list of stacks of crates.
 */
exports.parseStacks = (input) => {
  const stacksInput = input.split(/\n\n/)[0];
  const stacks = [];
  stacksInput.split(/\n/)
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
const moveCrate = (stacks, from, to) => {
  const crate = stacks[from].pop();
  stacks[to].push(crate);
};

const topCrates = (stacks) => {
  return stacks.map((stack) => stack[stack.length - 1]).join('');
};

exports.moveCrates = (stacks, steps) => {
  for (const step of steps) {
    for (let i = 0; i < step[0]; i++) {  // # crates to move
      moveCrate(stacks, step[1] - 1, step[2] - 1);
    }
  }
  return topCrates(stacks);
};

// TODO detect empty stack
const moveCrateGroup = (stacks, n, from, to) => {
  const temp = [];
  for (let i = 0; i < n; i++) {
    const crate = stacks[from].pop();
    temp.push(crate);
  }
  for (let i = 0; i < n; i++) {
    const crate = temp.pop();
    stacks[to].push(crate);
  }
};

exports.multiMoveCrates = (stacks, steps) => {
  for (const step of steps) {
    moveCrateGroup(stacks, step[0], step[1] - 1, step[2] - 1);
  }
  return topCrates(stacks);
};
