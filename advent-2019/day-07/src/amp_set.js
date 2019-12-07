'use strict';
const intcode = require('../src/intcode');
// Run program on a chain of amplifiers. Signal value "0" will be sent as
// input to the first amp in the chain. Each amp's output will be sent to
// the next amp's input.
//
// PARAMETERS
//   program: program to run (will not be altered)
//   settings: Array of amp phase settings (0..4), one per amp
//
// RETURNS
//   signal output from the last amp in the chain
const run = (program, settings) => {
  const values = [0];
  const popValue = () => values.shift();
  const pushValue = (v) => values.unshift(v);
  for (const setting of settings) {
    // "Make sure that memory is not shared or reused between copies of the program."
    const programCopy = program.slice();
    // Intcode inputs: FIRST the amp phase setting, SECOND the signal value
    values.unshift(setting);
    intcode.run(programCopy, false, popValue, pushValue);
  }
  return values[0];
};
exports.run = run;
