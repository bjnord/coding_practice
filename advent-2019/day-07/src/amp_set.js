'use strict';
const intcode = require('../../shared/src/intcode');
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
  const getValue = () => values.shift();
  const storeValue = (v) => values.push(v);
  for (const setting of settings) {
    // "Make sure that memory is not shared or reused between copies of the program."
    const programCopy = program.slice();
    // Intcode inputs: FIRST the amp phase setting, SECOND the signal value
    values.unshift(setting);
    intcode.run(programCopy, false, getValue, storeValue);
  }
  return values[0];
};
// Run program on a chain of amplifiers in feedback mode. Signal value "0"
// will be sent as input to the first amp in the chain. Each amp's output
// will be sent to the next amp's input, with the last amp's output being
// sent back to the first amp's input again. This process continues until
// all amps have halted.
//
// PARAMETERS
//   program: program to run (will not be altered)
//   settings: Array of amp phase settings (5..9), one per amp
//
// RETURNS
//   signal output from the last amp in the chain, after all amps have halted
const runFeedback = (program, settings) => {
  const amps = settings.map((s) => ({
    program: program.slice(),
    values: [s],
    iState: {pc: 0},
  }));
  let curAmp = 0;
  const getValue = () => amps[curAmp].values.shift();
  const storeValue = (v) => amps[(curAmp+1) % settings.length].values.push(v);
  // Intcode inputs: FIRST the amp phase setting, SECOND the signal value
  amps[0].values.push(0);
  for (;;) {
    amps[curAmp].iState = intcode.run(amps[curAmp].program, false, getValue, storeValue, amps[curAmp].iState);
    if (amps.every((a) => a.iState.state === 'halt')) {
      break;
    }
    curAmp = (curAmp+1) % settings.length;
  }
  return amps[0].values[0];
};
exports.runFeedback = runFeedback;
exports.run = run;
