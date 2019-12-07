'use strict';
const reader = require('readline-sync');
const getOperands = (program, inst) => {
  return inst.modes.map((mode, i) => (mode === 1) ? inst.args[i] : program[inst.args[i]]);
};
// Run an Intcode program.
//
// PARAMETERS
//   program: the Intcode program to run - NOTE that programs can be
//     self-modifying ("program" is essentially a memory bank), so
//     run() may alter the contents of program
//   debug: if true, output instructions to the console (default false)
//   inCallback: "headless mode": rather than taking from stdin, the
//     IN instruction will call inCallback(), which is expected to
//     return the input value - NOTE that if inCallback() returns
//     undefined (no input available), execution will be paused (see
//     "RETURNS" below)
//   outCallback: "headless mode": rather than printing to stdout, the
//     OUT instruction will call outCallback(v) with the output value
//   startPc: initial program counter (PC) value (default 0)
//
// RETURNS
//   if running in "headless mode", and inCallback() returns undefined,
//     pauses execution and returns the PC at which execution should resume
//   otherwise returns -1 to indicate execution has halted
const run = (program, debug = false, inCallback = undefined, outCallback = undefined, startPc = 0) => {
  let pc = startPc;
  for (;;) {
    const inst = decode(program.slice(pc, pc+4));
    /* istanbul ignore if */
    if (debug) {
      console.debug(`[PC:${pc} ${instructionString(inst)}]`);
    }
    const op = getOperands(program, inst);
    let jump = false;
    switch (inst.opcodeName) {
    case 'ADD':
      program[inst.args[2]] = op[0] + op[1];
      break;
    case 'MUL':
      program[inst.args[2]] = op[0] * op[1];
      break;
    case 'IN':
      /* istanbul ignore else */
      if (inCallback) {
        const v = inCallback();
        if (v === undefined) {
          return pc;  // pause execution for input
        } else {
          program[inst.args[0]] = v;
        }
      } else {
        program[inst.args[0]] = Number(reader.question('INPUT: '));
      }
      break;
    case 'OUT':
      /* istanbul ignore else */
      if (outCallback) {
        outCallback(op[0]);
      } else {
        console.log(op[0]);
      }
      break;
    case 'JTRU':
      jump = (op[0] !== 0);
      break;
    case 'JFAL':
      jump = (op[0] === 0);
      break;
    case 'LT':
      program[inst.args[2]] = (op[0] < op[1]) ? 1 : 0;
      break;
    case 'EQ':
      program[inst.args[2]] = (op[0] === op[1]) ? 1 : 0;
      break;
    case 'HALT':
      break;
    default:
      throw new Error(`invalid opcode ${inst.opcode} at PC=${pc}`);
    }
    if (inst.opcodeName === 'HALT') {
      break;
    }
    if (jump) {
      pc = op[1];
    } else {
      pc += (inst.argCount + 1);
    }
  }
  return -1;
};
// TODO set "outputArg" attribute (2 for ADD/MUL, 0 for IN, null for others)
// (to be used for the exception, below)
const splitOpcode = (instruction) => {
  const opcode = instruction % 100;
  instruction -= opcode;
  const opcodeName = {1: 'ADD', 2: 'MUL', 3: 'IN', 4: 'OUT', 5: 'JTRU', 6: 'JFAL', 7: 'LT',  8: 'EQ',  99: 'HALT'}[opcode];
  const argCount =   {1: 3,     2: 3,     3: 1,    4: 1,     5: 2,      6: 2,      7: 3,     8: 3,     99: 0}[opcode];
  const modes = [];
  for (let i = 0, mode = 100; i < argCount; i++, mode *= 10) {
    if ((instruction / mode) % 10 === 1) {
      modes[i] = 1;
      instruction -= mode;
    } else {
      modes[i] = 0;
    }
  }
  return {opcode, opcodeName, argCount, modes};
};
const instructionString = (inst) => {
  let str = inst.opcodeName;
  for (let i = 0; i < inst.argCount; i++) {
    str += ((i > 0) ? ',' : ' ');
    if (inst.modes[i] !== 1) {
      str += 'M';
    }
    str += inst.args[i];
  }
  return str;
};
// TODO throw an exception if mode violates this:
// "Parameters that an instruction writes to will never be in immediate mode."
const decode = (program) => {
  const o = splitOpcode(program[0]);
  o.args = program.slice(1, 1 + o.argCount);
  return o;
};
exports.run = run;
exports.instructionString = instructionString;
exports.decode = decode;
