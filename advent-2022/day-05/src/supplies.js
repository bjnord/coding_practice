'use strict';
/**
 * @module supplies
 *
 * @description
 *
 * The crate stacks data structure used in this module's functions is an
 * array of stacks (stack "1" first), each of which is an array of crates
 * (bottom crate first).
 *
 * The puzzle example:
 * ```
 *       [D]    
 *   [N] [C]    
 *   [Z] [M] [P]
 *    1   2   3 
 * ```
 *
 * ...would be represented as:
 * ```
 *   [
 *     ['Z', 'N'],
 *     ['M', 'C', 'D'],
 *     ['P'],
 *   ]
 * ```
 *
 * The procedure steps data structure used in this module's functions is an
 * array of steps, each of which is a three-element array of instructions:
 * - element 0: number of crates to move
 * - element 1: from stack number (1-relative)
 * - element 2: to stack number (1-relative)
 *
 * The puzzle example:
 * ```
 *   move 1 from 2 to 1
 *   move 3 from 1 to 3
 *   move 2 from 2 to 1
 *   move 1 from 1 to 2
 * ```
 *
 * ...would be represented as:
 * ```
 *   [
 *     [1, 2, 1],
 *     [3, 1, 3],
 *     [2, 2, 1],
 *     [1, 1, 2],
 *   ]
 * ```
 */
/**
 * Parse the stacks section of the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array.string}
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
/*
 * Move one crate from stack `from` to stack `to`.
 */
// TODO detect empty stack
const moveCrate = (stacks, from, to) => {
  const crate = stacks[from].pop();
  stacks[to].push(crate);
};
/*
 * Return a list of the top crate on each stack, as a string.
 */
const topCrates = (stacks) => {
  return stacks.map((stack) => stack[stack.length - 1]).join('');
};
/**
 * Perform the crate-moving procedure, moving one crate at a time.
 *
 * @param {Array.Array.string} stacks - array of stacks of crates
 * @param {Array.Array.number} steps - list of procedure steps
 *
 * @returns {string}
 *   Returns a list of the top crate on each stack after all moves
 *   are completed.
 */
exports.moveCrates = (stacks, steps) => {
  for (const step of steps) {
    for (let i = 0; i < step[0]; i++) {  // # crates to move
      moveCrate(stacks, step[1] - 1, step[2] - 1);
    }
  }
  return topCrates(stacks);
};
/*
 * Move `n` crates (as a group, all at once) from stack `from` to
 * stack `to`.
 */
// TODO detect empty stack
const moveCrateGroup = (stacks, n, from, to) => {
  const group = stacks[from].splice(stacks[from].length - n, n);
  stacks[to].push(...group);
};
/**
 * Perform the crate-moving procedure, moving multiple crates at once.
 *
 * @param {Array.Array.string} stacks - array of stacks of crates
 * @param {Array.Array.number} steps - list of procedure steps
 *
 * @returns {string}
 *   Returns a list of the top crate on each stack after all moves
 *   are completed.
 */
exports.multiMoveCrates = (stacks, steps) => {
  for (const step of steps) {
    moveCrateGroup(stacks, step[0], step[1] - 1, step[2] - 1);
  }
  return topCrates(stacks);
};
