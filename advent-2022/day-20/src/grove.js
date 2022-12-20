'use strict';
const math = require('../../shared/src/math');
const _debug = false;
/** @module grove */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of numbers.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `...`)
 *
 * @return {Object}
 *   Returns a number.
 */
exports.parseLine = (line) => {
  return parseInt(line);
};

exports.state = ((numbers) => {
  const count = numbers.length;
  // h/t https://stackoverflow.com/a/10050831/291754
  const slots = [...Array(count).keys()];
  const slotIndex = [...Array(count).keys()];
  return {
    count,
    numbers: [...numbers],
    curIndex: 0,
    slots,
    slotIndex,
  };
});

exports.currentNumbers = ((state) => {
  const curNumbers = state.slots.map((slot) => state.numbers[slot]);
  if (_debug) {
    console.debug('numbers now:')
    console.dir(curNumbers);
  }
  return curNumbers;
});

exports.rotateLeft = ((state, fromSlot, toSlot) => {
  if (fromSlot < 0) {
    throw new SyntaxError(`fromSlot=${fromSlot} < 0`);
  } else if (toSlot >= state.count) {
    throw new SyntaxError(`fromSlot=${fromSlot} >= count=${state.count}`);
  } else if (fromSlot > toSlot) {
    throw new SyntaxError(`fromSlot=${fromSlot} > toSlot=${toSlot}`);
  }
  const original = state.slots[fromSlot];
  for (let i = fromSlot; i < toSlot; i++) {
    const modI = math.mod(i, state.count);
    const old = state.slots[modI];
    state.slots[modI] = state.slots[math.mod(i + 1, state.count)];
    if (_debug) {
      console.debug(`  modI=${modI} old=${old} new=${state.slots[modI]}`);
    }
    state.slotIndex[state.slots[modI]] = modI;
  }
  // FIXME DRY same as loop guts, except `original`
  const modI = math.mod(toSlot, state.count);
  const old = state.slots[modI];
  state.slots[modI] = original;
  if (_debug) {
    console.debug(`  modI=${modI} old=${old} new=${state.slots[modI]}`);
  }
  state.slotIndex[state.slots[modI]] = modI;
});

exports.rotateRight = ((state, fromSlot, toSlot) => {
  if (fromSlot < 0) {
    throw new SyntaxError(`fromSlot=${fromSlot} < 0`);
  } else if (toSlot >= state.count) {
    throw new SyntaxError(`fromSlot=${fromSlot} >= count=${state.count}`);
  } else if (fromSlot > toSlot) {
    throw new SyntaxError(`fromSlot=${fromSlot} > toSlot=${toSlot}`);
  }
  const original = state.slots[toSlot];
  for (let i = toSlot; i > fromSlot; i--) {
    const modI = math.mod(i, state.count);
    const old = state.slots[modI];
    state.slots[modI] = state.slots[math.mod(i - 1, state.count)];
    if (_debug) {
      console.debug(`  modI=${modI} old=${old} new=${state.slots[modI]}`);
    }
    state.slotIndex[state.slots[modI]] = modI;
  }
  // FIXME DRY same as loop guts, except `original`
  const modI = math.mod(fromSlot, state.count);
  const old = state.slots[modI];
  state.slots[modI] = original;
  if (_debug) {
    console.debug(`  modI=${modI} old=${old} new=${state.slots[modI]}`);
  }
  state.slotIndex[state.slots[modI]] = modI;
});

/*
 * The rules for movement, as shown in the puzzle example, are NOT
 * simple modulo arithmetic. Movement never includes numbers at both
 * ends; it's always a single range that gets rotated.
 */
exports.destSlot = ((curNumber, curSlot, count) => {
  let destSlot = curSlot + curNumber;
  if (_debug) {
    console.debug(`curSlot=${curSlot} curNumber=${curNumber} INITIAL destSlot=${destSlot}`);
  }
  if (destSlot >= count) {
    destSlot = math.mod(destSlot + 1, count);
  } else if (destSlot <= 0) {
    destSlot = math.mod(destSlot - 1, count);
  }
  if (_debug) {
    console.debug(`curSlot=${curSlot} curNumber=${curNumber}   FINAL destSlot=${destSlot}`);
  }
  return destSlot;
});

exports.doMove = ((state) => {
  if (state.curIndex >= state.count) {
    throw new SyntaxError('moves exhausted');
  }
  // "what's the current position (`curSlot`) of the number that
  // originally was in `curIndex`?"
  const curSlot = state.slotIndex[state.curIndex];
  const curNumber = state.numbers[state.slots[curSlot]];
  if (_debug) {
    module.exports.currentNumbers(state);
    console.debug(`move i=${state.curIndex}: moving ${curNumber} currently in slot=${curSlot}`);
  }

  // no move
  if (curNumber === 0) {
    if (_debug) {
      console.debug(`  no move`);
    }
  }
  // move off the right edge
  else if ((curSlot + curNumber) >= state.count) {
    const destSlot = module.exports.destSlot(curNumber, curSlot, state.count);
    module.exports.rotateRight(state, destSlot, curSlot);
  }
  // all other moves (including moving off the left edge)
  else {
    const destSlot = module.exports.destSlot(curNumber, curSlot, state.count);
    module.exports.rotateLeft(state, curSlot, destSlot);
  }

  if (_debug) {
    console.debug('slots now:')
    console.dir(state.slots);
    console.debug('slotIndex now:')
    console.dir(state.slotIndex);
    console.debug('--');
  }
  state.curIndex++;
});

exports.doMoves = ((state) => {
  for (let i = 0; i < state.count; i++) {
    module.exports.doMove(state);
  }
});

exports.coordinates = ((state) => {
  if (state.curIndex < state.count) {
    throw new SyntaxError('not all moves made');
  }
  if (_debug) {
    console.debug('');
    console.debug('**********');
  }
  const currentNumbers = module.exports.currentNumbers(state);
  if (_debug) {
    console.debug('slots now:')
    console.dir(state.slots);
    console.debug('slotIndex now:')
    console.dir(state.slotIndex);
  }
  const zeroIndex = state.numbers.indexOf(0);
  // "what's the current position (`curSlot`) of the number that
  // originally was in `zeroIndex`?"
  const zeroSlot = state.slotIndex[zeroIndex];
  const zeroNumber = state.numbers[state.slots[zeroSlot]];
  if (zeroNumber !== 0) {
    throw new SyntaxError("didn't find 0 where expected");
  }
  if (_debug) {
    console.debug(`zeroIndex=${zeroIndex} zeroSlot=${zeroSlot} zeroNumber=${zeroNumber}`);
  }
  const coords = [];
  for (const i of [1000, 2000, 3000]) {
    const coordSlot = math.mod(zeroSlot + i, state.count);
    const coordNumber = currentNumbers[coordSlot];
    if (_debug) {
      console.debug(`i=${i} coordSlot=${coordSlot} coordNumber=${coordNumber}`);
    }
    coords.push(coordNumber);
  }
  return coords;
});
