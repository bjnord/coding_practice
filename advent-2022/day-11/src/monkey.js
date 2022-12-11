'use strict';
/** @module monkey */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - sections of puzzle input separated by `\n\n`
 *
 * @return {Array.Object}
 *   Returns a list of monkeys.
 */
exports.parse = (input) => {
  return input.trim().split(/\n\n/).map((section) => module.exports.parseSection(section));
};
/*
 * Parse operation argument from token.
 */
const argFromToken = ((tok) => {
  if (tok === 'old') {
    return null;
  } else {
    return parseInt(tok);
  }
});
/**
 * Parse one section from the puzzle input.
 *
 * Example of one section:
 * ```
 *   Monkey 0:
 *     Starting items: 79, 98
 *     Operation: new = old * 19
 *     Test: divisible by 23
 *       If true: throw to monkey 2
 *       If false: throw to monkey 3
 * ```
 *
 * @param {string} lines - lines of section input
 *
 * @return {Object}
 *   Returns a monkey.
 */
exports.parseSection = (section) => {
  const lines = section.split(/\n/).map((line) => line.trim());
  const nMatch = lines[0].match(/Monkey\s+(\d+):/);
  const n = parseInt(nMatch[1]);
  const itemMatch = lines[1].match(/Starting\s+items:\s+(.*)/);
  const items = itemMatch[1].split(/,\s+/).map((tok) => parseInt(tok));
  const instMatch = lines[2].match(/Operation:\s+new\s+=\s+(\S+)\s+(\S+)\s+(\S+)$/);
  const inst = {
    arg1: argFromToken(instMatch[1]),
    op: instMatch[2],
    arg2: argFromToken(instMatch[3]),
  };
  const testDivMatch = lines[3].match(/Test:\s+divisible\s+by\s+(\d+)/);
  const testDiv = parseInt(testDivMatch[1]);
  const trueMonkeyMatch = lines[4].match(/If\s+true:\s+throw\s+to\s+monkey\s+(\d+)/);
  const trueMonkey = parseInt(trueMonkeyMatch[1]);
  const falseMonkeyMatch = lines[5].match(/If\s+false:\s+throw\s+to\s+monkey\s+(\d+)/);
  const falseMonkey = parseInt(falseMonkeyMatch[1]);
  return {n, nInspect: 0, items, inst, testDiv, trueMonkey, falseMonkey};
};

exports.runInst = ((item, inst) => {
  switch (inst.op) {
  case '*':
    if (inst.arg2) {
      return item * inst.arg2;
    } else {
      return item * item;
    }
  case '+':
    if (inst.arg2) {
      return item + inst.arg2;
    } else {
      return item + item;
    }
  default:
    throw new SyntaxError(`unknown op ${inst.op}`);
  }
});

exports.runRound = ((monkeys) => {
  //console.debug('BEFORE:');
  //console.dir(monkeys.map((m) => m.items));
  for (const m of monkeys) {
    while (m.items.length > 0) {
      const item = m.items.shift();
      const newItem = Math.floor(module.exports.runInst(item, m.inst) / 3);
      m.nInspect++;
      if ((newItem % m.testDiv) === 0) {
        //console.debug(`T: Item with worry level ${newItem} is thrown to monkey ${m.trueMonkey}`);
        monkeys[m.trueMonkey].items.push(newItem);
      } else {
        //console.debug(`F: Item with worry level ${newItem} is thrown to monkey ${m.falseMonkey}`);
        monkeys[m.falseMonkey].items.push(newItem);
      }
    }
  }
  //console.debug('AFTER:');
  //console.dir(monkeys.map((m) => m.items));
});

exports.mostActive = ((monkeys) => {
  return monkeys.map((m) => m.nInspect)
    .sort((a, b) => Math.sign(b - a))
    .slice(0, 2);
});
