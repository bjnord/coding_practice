'use strict';
/** @module processor */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of instructions.
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
 *   Returns an instruction.
 */
exports.parseLine = (line) => {
  const tokens = line.split(/\s+/);
  const inst = {op: tokens[0]};
  if (inst.op === 'addx') {
    inst.arg = parseInt(tokens[1]);
  }
  return inst;
};

exports.signalStrengths = ((program) => {
  let cycle = 1;
  let x = 1;
  const ss = [];
  for (const inst of program) {
    if (inst.op === 'addx') {
      if (((cycle + 20) % 40) === 0) {
        // now "during" the first of two cycles needed for `addx`
        ss.push(cycle * x);
      }
      cycle++;
      if (((cycle + 20) % 40) === 0) {
        // now "during" the second of two cycles needed for `addx`
        ss.push(cycle * x);
      }
      // now "after" the two cycles needed for `addx`
      x += inst.arg;
    } else {  // noop
      if (((cycle + 20) % 40) === 0) {
        // "during" the lone cycle needed for `noop`
        ss.push(cycle * x);
      }
    }
    cycle++;
    if (ss.length >= 6) {
      break;
    }
  }
  return ss;
});

exports.pixelLit = ((cycle, x) => {
  const pos = (cycle - 1) % 40;
  return ((pos >= x - 1) && (pos <= x + 1));
});

exports.renderPixels = ((program) => {
  let cycle = 1;
  let x = 1;
  const pixels = [];
  for (const inst of program) {
    if (inst.op === 'addx') {
      // now "during" the first of two cycles needed for `addx`
      pixels.push(module.exports.pixelLit(cycle, x));
      cycle++;
      if (cycle > 240) {
        break;
      }
      // now "during" the second of two cycles needed for `addx`
      pixels.push(module.exports.pixelLit(cycle, x));
      // now "after" the two cycles needed for `addx`
      x += inst.arg;
    } else {  // noop
      // "during" the lone cycle needed for `noop`
      pixels.push(module.exports.pixelLit(cycle, x));
    }
    cycle++;
    if (cycle > 240) {
      break;
    }
  }
  return pixels;
});

exports.dumpPixels = ((pixels) => {
  const str = pixels.map((px) => px ? '#' : '.')
    .reduce((str, ch) => str + ch, '');
  for (let i = 0; i < 240; i += 40) {
    console.log(str.substring(i, i + 40));
  }
});
