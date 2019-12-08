'use strict';
const reader = require('readline-sync');
const ifunc = {};

// Terminology note: I use
// - "argument" to mean the raw value stored in the program
// - "operand" to mean the value actually operated on, after fetching
//   the value according to the mode
const getOperands = (program, inst) => {
  return inst.modes.map((mode, i) => (mode === 1) ? inst.args[i] : program[inst.args[i]]);
};
const getStoreIndex = (inst) => {
  return inst.args[inst.storeArgIndex];
};

// run(): Run an Intcode program.
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
    const ifuncName = 'do'+inst.opcodeName;
    if (!ifunc[ifuncName]) {
      throw new Error(`invalid opcode ${inst.opcode} at PC=${pc}`);
    }
    const state = ifunc[ifuncName](program, op, getStoreIndex(inst), inCallback, outCallback);
    switch (state) {
    case 'iowait':
      return pc;
    case 'halt':
      return -1;
    case 'run':
      pc += (inst.argCount + 1);
      break;
    case 'jump':
      pc = op[1];
      break;
    /* istanbul ignore next */
    default:
      throw new Error(`invalid state ${state} from do${inst.opcodeName}()`);
    }
  }
};

////////////////////////////////////////////////////////////////////////////
// BEGIN Intcode instruction functions
//
// each of these functions handles one instruction type
// they return one of the following:
//
//   'iowait': stop execution waiting for I/O
//   'halt': halt execution
//   'run': continue execution with next instruction
//   'jump': jump to new instruction, then continue execution
//
ifunc.doADD = (program, op, storeIndex) => {
  program[storeIndex] = op[0] + op[1];
  return 'run';
};
ifunc.doMUL = (program, op, storeIndex) => {
  program[storeIndex] = op[0] * op[1];
  return 'run';
};
ifunc.doIN = (program, op, storeIndex, inCallback) => {
  /* istanbul ignore else */
  if (inCallback) {
    const v = inCallback();
    if (v === undefined) {
      return 'iowait';
    } else {
      program[storeIndex] = v;
    }
  } else {
    program[storeIndex] = Number(reader.question('INPUT: '));
  }
  return 'run';
};
// use destructuring to avoid lint "unused argument" errors
// h/t <https://stackoverflow.com/a/58738236/291754>
ifunc.doOUT = (...[, op, , , outCallback]) => {
  /* istanbul ignore else */
  if (outCallback) {
    outCallback(op[0]);
  } else {
    console.log(op[0]);
  }
  return 'run';
};
ifunc.doJTRU = (program, op) => {
  return (op[0] !== 0) ? 'jump' : 'run';
};
ifunc.doJFAL = (program, op) => {
  return (op[0] === 0) ? 'jump' : 'run';
};
ifunc.doLT = (program, op, storeIndex) => {
  program[storeIndex] = (op[0] < op[1]) ? 1 : 0;
  return 'run';
};
ifunc.doEQ = (program, op, storeIndex) => {
  program[storeIndex] = (op[0] === op[1]) ? 1 : 0;
  return 'run';
};
ifunc.doHALT = () => {
  return 'halt';
};
//
// END Intcode instruction functions
////////////////////////////////////////////////////////////////////////////

// decode(): Decode an instruction and its arguments.
const decode = (program) => {
  const o = splitOpcode(program[0]);
  o.args = program.slice(1, 1 + o.argCount);
  return o;
};

// splitOpcode(): Decode the opcode portion of an instruction.
//
// This does the bulk of the work for decode(). See also "Terminology note"
// (above).
const splitOpcode = (instruction) => {
  const opcode = instruction % 100;
  instruction -= opcode;
  const opcodeName =    {1: 'ADD', 2: 'MUL', 3: 'IN', 4: 'OUT', 5: 'JTRU', 6: 'JFAL', 7: 'LT',  8: 'EQ',  99: 'HALT'}[opcode];
  const argCount =      {1: 3,     2: 3,     3: 1,    4: 1,     5: 2,      6: 2,      7: 3,     8: 3,     99: 0}[opcode];
  // which argument does the instruction store the result to (if any)?
  const storeArgIndex = {1: 2,     2: 2,     3: 0,    4: null,  5: null,   6: null,   7: 2,     8: 2,     99: null}[opcode];
  // the mode of each argument: 0=positional(indirect) 1=immediate
  const modes = [];
  for (let i = 0, mode = 100; i < argCount; i++, mode *= 10) {
    if ((instruction / mode) % 10 === 1) {
      modes[i] = 1;
      instruction -= mode;  // TODO is this needed?
    } else {
      modes[i] = 0;
    }
  }
  // "Parameters that an instruction writes to will never be in immediate mode."
  if (modes[storeArgIndex] === 1) {
    throw new Error('immediate mode is invalid for store argument');
  }
  return {opcode, opcodeName, argCount, storeArgIndex, modes};
};

// Reencode ("disassemble") an instruction to a string suitable for debug output.
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

exports.run = run;
exports.instructionString = instructionString;
exports.decode = decode;
