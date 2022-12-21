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

exports.monkeyNumbers = ((monkeys) => {
  const monkeyNumbers = monkeys.reduce((h, monkey) => {
    if (monkey.number !== undefined) {
      if (_debug) {
        console.debug(`monkey ${monkey.name} immediately yells ${monkey.number}`);
      }
      h[monkey.name] = monkey.number;
    }
    return h;
  }, {});
  let monkeysLeft = monkeys.length - Object.keys(monkeyNumbers).length;
  while (monkeysLeft > 0) {
    for (const monkey of monkeys) {
      if (monkey.number === undefined) {
        if ((monkeyNumbers[monkey.arg1] !== undefined) && (monkeyNumbers[monkey.arg2] !== undefined)) {
          let number;
          switch (monkey.op) {
            case '+':
              number = monkeyNumbers[monkey.arg1] + monkeyNumbers[monkey.arg2];
              break;
            case '-':
              number = monkeyNumbers[monkey.arg1] - monkeyNumbers[monkey.arg2];
              break;
            case '*':
              number = monkeyNumbers[monkey.arg1] * monkeyNumbers[monkey.arg2];
              break;
            case '/':
              number = monkeyNumbers[monkey.arg1] / monkeyNumbers[monkey.arg2];
              break;
            default:
              throw new SyntaxError(`unknown op ${monkey.op}`);
          }
          monkey.number = number;
          if (_debug) {
            console.debug(`monkey ${monkey.name} can now yell ${monkey.number}`);
          }
          monkeyNumbers[monkey.name] = number;
          monkeysLeft--;
        }
      }
    }
  }
  return monkeyNumbers;
});

exports.humanYell = ((monkeys, monkeyNumbers) => {
  const parentOfName = {};
  const monkeyOfName = {};
  for (const monkey of monkeys) {
    if (monkey.op) {
      parentOfName[monkey.arg1] = monkey;
      parentOfName[monkey.arg2] = monkey;
    }
    monkeyOfName[monkey.name] = monkey;
  }
  if (_debug) {
    console.debug('parentOfName:');
    console.dir(parentOfName);
    console.debug('monkeyOfName:');
    console.dir(monkeyOfName);
  }
  let humanBranch;
  let opStack = [];
  for (let n = 'humn', m = parentOfName[n]; m; n = m.name, m = parentOfName[n]) {
    // m is "the monkey with n as one of its arguments"
    if (m.arg1 === n) {
      opStack.push({op: m.op, arg: monkeyOfName[m.arg2].number});
    } else if (m.arg2 === n) {
      const arg = monkeyOfName[m.arg1].number;
      if (m.op === '-') {
        // n - 4  =  n + (-4)
        opStack.push({op: '+', arg: -arg});
      } else if (m.op === '/') {
        // n / 4  =  n * (1 / 4)
        opStack.push({op: '*', arg: 1 / arg});
      } else {
        opStack.push({op: m.op, arg});
      }
    } else {
      throw new SyntaxError(`n ${n} not found as arg of ${m.name}`);
    }
    if (parentOfName[m.name].name == 'root') {
      humanBranch = m;
      break;
    }
  }
  if (_debug) {
    console.debug('humanBranch:');
    console.dir(humanBranch);
    console.debug('opStack:');
    console.dir(opStack);
  }
  const root = monkeyOfName['root'];
  let rootValue;
  if (root.arg1 === humanBranch.name) {
    rootValue = monkeyOfName[root.arg2].number;
  } else if (root.arg2 === humanBranch.name) {
    rootValue = monkeyOfName[root.arg2].number;
  } else {
    throw new SyntaxError("can't determine rootValue");
  }
  if (_debug) {
    console.debug(`rootValue=${rootValue}`);
  }
  while (opStack.length > 0) {
    const op = opStack.pop();
    const oldValue = rootValue;
    // we do the inverse
    switch (op.op) {
      case '+':
        rootValue -= op.arg;
        break;
      case '-':
        rootValue += op.arg;
        break;
      case '*':
        rootValue /= op.arg;
        break;
      case '/':
        rootValue *= op.arg;
        break;
      default:
        throw new SyntaxError(`unknown op.op ${op.op}`);
    }
    if (_debug) {
      console.debug(`oldValue=${oldValue} op=${op.op} arg=${op.arg} rootValue=${rootValue}`);
    }
  }
  return rootValue;
});
