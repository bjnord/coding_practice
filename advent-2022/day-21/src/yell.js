'use strict';
const _debug = false;
/** @module yell */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of monkeys.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `root: pppw + sjmn` or `dbpl: 5`)
 *
 * @return {Object}
 *   Returns a monkey.
 */
exports.parseLine = (line) => {
  const kv = line.split(': ');
  const monkey = {name: kv[0]};
  const op = kv[1].split(' ');
  if (op.length === 1) {
    monkey['number'] = parseInt(op[0]);
  } else if (op.length === 3) {
    monkey['arg1'] = op[0];
    monkey['op'] = op[1];
    monkey['arg2'] = op[2];
  } else {
    throw new SyntaxError(`invalid line value [${kv[1]}]`);
  }
  return monkey;
};

exports.rootMonkeyNumber = ((monkeys) => {
  const monkeyNumber = monkeys.reduce((h, monkey) => {
    if (monkey.number !== undefined) {
      if (_debug) {
        console.debug(`monkey ${monkey.name} immediately yells ${monkey.number}`);
      }
      h[monkey.name] = monkey.number;
    }
    return h;
  }, {});
  let monkeysLeft = monkeys.length - Object.keys(monkeyNumber).length;
  while (monkeysLeft > 0) {
    for (const monkey of monkeys) {
      if (monkey.number === undefined) {
        if ((monkeyNumber[monkey.arg1] !== undefined) && (monkeyNumber[monkey.arg2] !== undefined)) {
          let number;
          switch (monkey.op) {
            case '+':
              number = monkeyNumber[monkey.arg1] + monkeyNumber[monkey.arg2];
              break;
            case '-':
              number = monkeyNumber[monkey.arg1] - monkeyNumber[monkey.arg2];
              break;
            case '*':
              number = monkeyNumber[monkey.arg1] * monkeyNumber[monkey.arg2];
              break;
            case '/':
              number = monkeyNumber[monkey.arg1] / monkeyNumber[monkey.arg2];
              break;
            default:
              throw new SyntaxError(`unknown op ${monkey.op}`);
          }
          monkey.number = number;
          if (_debug) {
            console.debug(`monkey ${monkey.name} can now yell ${monkey.number}`);
          }
          monkeyNumber[monkey.name] = number;
          monkeysLeft--;
          if (monkey.name === 'root') {
            return monkey.number;
          }
        }
      }
    }
  }
});
