'use strict';
const math = require('../../shared/src/math');
const _debug = false;
const _assertIntegrity = true;
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

const assertIntegrity = ((state) => {
  const expSum = ((state.count - 1) * state.count) / 2;
  const slotsSum = state.slots.reduce((sum, s) => sum + s, 0);
  /* istanbul ignore next */
  if (slotsSum !== expSum) {
    console.dir(state.slots);
    throw new SyntaxError('state.slots integrity fail');
  }
  const slotIndexSum = state.slotIndex.reduce((sum, si) => sum + si, 0);
  /* istanbul ignore next */
  if (slotIndexSum !== expSum) {
    console.dir(state.slotIndex);
    throw new SyntaxError('state.slotIndex integrity fail');
  }
});

exports.currentNumbers = ((state) => {
  const curNumbers = state.slots.map((slot) => state.numbers[slot]);
  /* istanbul ignore next */
  if (_debug) {
    console.debug('numbers now:');
    console.dir(curNumbers);
  }
  return curNumbers;
});

exports.rotatedEqual = ((a, b) => {
  if (a.length !== b.length) {
    throw new SyntaxError(`a.length ${a.length} !== b.length ${b.length}`);
  }
  const bRot = [...b];
  for (let i = 0; i < a.length; i++) {
    const el = bRot.shift();
    bRot.push(el);
    let equal = true;
    for (let j = 0; j < a.length; j++) {
      if (a[j] !== bRot[j]) {
        equal = false;
        break;
      }
    }
    if (equal) {
      return true;
    }
  }
  return false;
});

exports.rotateLeft = ((state, slot, dist) => {
  if (slot < 0) {
    throw new SyntaxError(`slot=${slot} < 0`);
  } else if (slot >= state.count) {
    throw new SyntaxError(`slot=${slot} >= count=${state.count}`);
  } else if (dist <= 0) {
    throw new SyntaxError(`dist=${dist} <= 0`);
  }
  const original = state.slots[slot];
  for (let i = slot; i <= slot + dist; i++) {
    const modI = math.mod(i, state.count);
    const old = state.slots[modI];
    const modJ = math.mod(i + 1, state.count);
    state.slots[modI] = (i === slot + dist) ? original : state.slots[modJ];
    /* istanbul ignore next */
    if (_debug) {
      console.debug(`  modI=${modI} old=${old} new=${state.slots[modI]}`);
    }
    state.slotIndex[state.slots[modI]] = modI;
  }
});

exports.rotateRight = ((state, slot, dist) => {
  if (slot < 0) {
    throw new SyntaxError(`slot=${slot} < 0`);
  } else if (slot >= state.count) {
    throw new SyntaxError(`slot=${slot} >= count=${state.count}`);
  } else if (dist >= 0) {
    throw new SyntaxError(`dist=${dist} >= 0`);
  }
  const original = state.slots[slot];
  for (let i = slot; i >= slot + dist; i--) {
    const modI = math.mod(i, state.count);
    const old = state.slots[modI];
    const modJ = math.mod(i - 1, state.count);
    state.slots[modI] = (i === slot + dist) ? original : state.slots[modJ];
    /* istanbul ignore next */
    if (_debug) {
      console.debug(`  modI=${modI} old=${old} new=${state.slots[modI]}`);
    }
    state.slotIndex[state.slots[modI]] = modI;
  }
});

exports.doMove = ((state) => {
  // "what's the current position (`curSlot`) of the number that
  // originally was in `curIndex`?"
  const curSlot = state.slotIndex[state.curIndex];
  const curNumber = state.numbers[state.slots[curSlot]];
  /* istanbul ignore next */
  if (_debug) {
    module.exports.currentNumbers(state);
    console.debug(`move i=${state.curIndex}: moving ${curNumber} currently in slot=${curSlot}`);
  }

  const dist = math.mod(curNumber, state.count - 1);
  // no move
  if (dist === 0) {
    /* istanbul ignore next */
    if (_debug) {
      console.debug('  no move');
    }
  }
  // move left
  else if (curNumber < 0) {
    module.exports.rotateRight(state, curSlot, dist - (state.count - 1));
  }
  // move right
  else {
    module.exports.rotateLeft(state, curSlot, dist);
  }

  /* istanbul ignore next */
  if (_assertIntegrity) {
    assertIntegrity(state);
  }
  /* istanbul ignore next */
  if (_debug) {
    console.debug('slots now:');
    console.dir(state.slots);
    console.debug('slotIndex now:');
    console.dir(state.slotIndex);
    console.debug('--');
  }
  if (++state.curIndex >= state.count) {
    state.curIndex = 0;
  }
});

exports.doMoves = ((state) => {
  for (let i = 0; i < state.count; i++) {
    module.exports.doMove(state);
  }
});

exports.coordinates = ((state) => {
  if (state.curIndex !== 0) {
    throw new SyntaxError('not all moves made');
  }
  /* istanbul ignore next */
  if (_debug) {
    console.debug('');
    console.debug('**********');
  }
  const currentNumbers = module.exports.currentNumbers(state);
  /* istanbul ignore next */
  if (_debug) {
    console.debug('slots now:');
    console.dir(state.slots);
    console.debug('slotIndex now:');
    console.dir(state.slotIndex);
  }
  const zeroIndex = state.numbers.indexOf(0);
  // "what's the current position (`curSlot`) of the number that
  // originally was in `zeroIndex`?"
  const zeroSlot = state.slotIndex[zeroIndex];
  const zeroNumber = state.numbers[state.slots[zeroSlot]];
  /* istanbul ignore next */
  if (zeroNumber !== 0) {
    throw new SyntaxError("didn't find 0 where expected");
  }
  /* istanbul ignore next */
  if (_debug) {
    console.debug(`zeroIndex=${zeroIndex} zeroSlot=${zeroSlot} zeroNumber=${zeroNumber}`);
  }
  const coords = [];
  for (const i of [1000, 2000, 3000]) {
    const coordSlot = math.mod(zeroSlot + i, state.count);
    const coordNumber = currentNumbers[coordSlot];
    /* istanbul ignore next */
    if (_debug) {
      console.debug(`i=${i} coordSlot=${coordSlot} coordNumber=${coordNumber}`);
    }
    coords.push(coordNumber);
  }
  return coords;
});

exports.keyTransform = ((numbers) => {
  return numbers.map((n) => n * 811589153);
});
