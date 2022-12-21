'use strict';
const mathjs = require('mathjs');
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
  const kj = line.split(': ');
  const monkey = {name: kj[0]};
  const job = kj[1].split(' ');
  if (job.length === 1) {
    monkey['number'] = parseInt(job[0]);
  } else if (job.length === 3) {
    monkey['arg1'] = job[0];
    monkey['op'] = job[1];
    monkey['arg2'] = job[2];
  } else {
    throw new SyntaxError(`invalid line value [${kj[1]}]`);
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

// TODO double-check that mathjs doesn't have a way to do this?
const reciprocal = ((n) => {
  const pair = mathjs.format(n).split('/').map((d) => parseInt(d));
  if (pair.length === 1) {
    return mathjs.fraction(1, pair[0]);
  } else if (pair.length === 2) {
    return mathjs.fraction(pair[1], pair[0]);
  } else {
    return undefined;
  }
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
  const jobStack = [];
  for (let n = 'humn', m = parentOfName[n]; m; n = m.name, m = parentOfName[n]) {
    // m is "the monkey with n as one of its arguments"
    if (m.arg1 === n) {
      if (_debug) {
        console.debug(`${n} ${m.op} ${monkeyOfName[m.arg2].number}`);
      }
      jobStack.push({op: m.op, arg: monkeyOfName[m.arg2].number});
    } else if (m.arg2 === n) {
      if (_debug) {
        console.debug(`${monkeyOfName[m.arg1].number} ${m.op} ${n}`);
      }
      jobStack.push({op: m.op, arg: monkeyOfName[m.arg1].number, commute: true});
    } else {
      throw new SyntaxError(`n ${n} not found as arg of ${m.name}`);
    }
    if (parentOfName[m.name].name === 'root') {
      humanBranch = m;
      break;
    }
  }
  if (_debug) {
    console.debug('humanBranch:');
    console.dir(humanBranch);
    console.debug('jobStack:');
    console.dir(jobStack);
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
  let yellValue = mathjs.fraction(rootValue, 1);
  while (jobStack.length > 0) {
    const job = jobStack.pop();
    const oldValue = yellValue;
    // we do the inverse
    switch (job.op) {
    case '+':
      // (n + 3) - 3 = n
      // (3 + n) - 3 = n
      yellValue = mathjs.subtract(yellValue, job.arg);
      break;
    case '-':
      if (job.commute) {
        // -((3 - n) - 3) = n
        yellValue = mathjs.unaryMinus(mathjs.subtract(yellValue, job.arg));
      } else {
        // (n - 3) + 3 = n
        yellValue = mathjs.add(yellValue, job.arg);
      }
      break;
    case '*':
      // (n * 3) / 3 = n
      // (3 * n) / 3 = n
      yellValue = mathjs.divide(yellValue, job.arg);
      break;
    case '/':
      if (job.commute) {
        // reciprocal(3 / n) * 3 = n
        yellValue = mathjs.multiply(reciprocal(yellValue), job.arg);
      } else {
        // (n / 3) * 3 = n
        yellValue = mathjs.multiply(yellValue, job.arg);
      }
      break;
    default:
      throw new SyntaxError(`unknown job.op ${job.op}`);
    }
    if (_debug) {
      console.debug(`oldValue=${oldValue} op=${job.op} arg=${job.arg} yellValue=${yellValue}`);
    }
  }
  return mathjs.number(yellValue);
});
