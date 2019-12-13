'use strict';
/** @module */
const reader = require('readline-sync');
const ifunc = {};

// Terminology note: I use
// - "argument" to mean the raw value stored in the program
// - "operand" to mean the value actually operated on, after fetching
//   the value according to the mode
const getOperands = (program, inst, iState) => {
  return inst.modes.map((mode, i) => {
    let loc;
    // "Memory beyond the initial program starts with the value 0"
    switch (mode) {
    case 1:   // immediate
      return inst.args[i];
    case 2:   // relative
      loc = inst.args[i] + iState.rb;
      return program[loc] ? program[loc] : 0;
    default:  // position
      loc = inst.args[i];
      return program[loc] ? program[loc] : 0;
    }
  });
};
const getStoreLocation = (inst, iState) => {
  const mode = inst.modes[inst.storeArgIndex];
  return inst.args[inst.storeArgIndex] + ((mode === 2) ? iState.rb : 0);
};

/**
 * Run an Intcode program.
 *
 * @param {Array} program - the Intcode program to run - **NOTE** that
 *   programs can be self-modifying (`program` is essentially a memory
 *   bank), so `run()` may alter the contents of `program`
 * @param {boolean} [debug=false] - if `true`, output instructions to the
 *   console
 * @param {function} [inCallback] - "headless mode": rather than taking
 *   from `stdin`, the IN instruction will call `inCallback()`, which is
 *   expected to return the input value - **NOTE** that if `inCallback()`
 *   returns `undefined` (no input available), execution will be paused
 *   (see "Returns" below)
 * @param {function} [outCallback] - "headless mode": rather than printing
 *   to `stdout`, the OUT instruction will call `outCallback(v)` with the
 *   output value
 * @param {object} [iState={pc: 0, rb: 0}] - initial Intcode state (Program
 *   Counter and Relative Base)
 *
 * @return {object}
 *   Returns Intcode state, with the following fields:
 *   - `pc` - current Program Counter (number)
 *   - `rb` - current Relative Base (number)
 *   - `state` - processor state (string):
 *     - `iowait` indicates the "headless mode" `inCallback()` returned
 *       `undefined`, and execution is paused for input (`pc` is where
 *       execution should resume)
 *     - `halt` indicates execution is halted
 */
exports.run = (program, debug = false, inCallback = undefined, outCallback = undefined, iState = {pc: 0, rb: 0}) => {
  for (;;) {
    const inst = module.exports.decode(program.slice(iState.pc, iState.pc+4));
    /* istanbul ignore if */
    if (debug) {
      console.debug(`[PC:${iState.pc} RB:${iState.rb} ${module.exports.instructionString(inst)}]`);
    }
    const op = getOperands(program, inst, iState);
    const ifuncName = 'do'+inst.opcodeName;
    if (!ifunc[ifuncName]) {
      throw new Error(`invalid opcode ${inst.opcode} at PC=${iState.pc}`);
    }
    const state = ifunc[ifuncName](program, op, getStoreLocation(inst, iState), inCallback, outCallback, iState);
    switch (state) {
    case 'iowait':
      // PC is unchanged (resume from same IN instruction)
      iState.state = 'iowait';
      return iState;
    case 'halt':
      iState.pc += (inst.argCount + 1);
      iState.state = 'halt';
      return iState;
    case 'run':
      iState.pc += (inst.argCount + 1);
      break;
    case 'jump':
      iState.pc = op[1];
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
// Each of these functions handles one instruction type. They return one of
// the following:
//
//   'iowait': stop execution waiting for I/O
//   'halt': halt execution
//   'run': continue execution with next instruction
//   'jump': jump to new instruction, then continue execution
//
ifunc.doADD = (program, op, storeLocation) => {
  program[storeLocation] = op[0] + op[1];
  return 'run';
};
ifunc.doMUL = (program, op, storeLocation) => {
  program[storeLocation] = op[0] * op[1];
  return 'run';
};
ifunc.doIN = (program, op, storeLocation, inCallback) => {
  /* istanbul ignore else */
  if (inCallback) {
    const v = inCallback();
    if (v === undefined) {
      return 'iowait';
    } else {
      program[storeLocation] = v;
    }
  } else {
    program[storeLocation] = Number(reader.question('INPUT: '));
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
ifunc.doLT = (program, op, storeLocation) => {
  program[storeLocation] = (op[0] < op[1]) ? 1 : 0;
  return 'run';
};
ifunc.doEQ = (program, op, storeLocation) => {
  program[storeLocation] = (op[0] === op[1]) ? 1 : 0;
  return 'run';
};
// use destructuring to avoid lint "unused argument" errors
// h/t <https://stackoverflow.com/a/58738236/291754>
ifunc.doARB = (...[, op, , , , iState]) => {
  iState.rb += op[0];
  return 'run';
};
ifunc.doHALT = () => {
  return 'halt';
};
//
// END Intcode instruction functions
////////////////////////////////////////////////////////////////////////////

/**
 * Decode an instruction and its arguments.
 *
 * @param {Array} program - subset of program containing instruction to
 *   decode
 *
 * @return {object}
 *   Returns the decoded instruction, with the following fields:
 *   - `opcode` - opcode (number)
 *   - `opcodeName` - opcode name (string)
 *   - `argCount` - number of arguments the instruction takes
 *   - `storeArgIndex` - argument the instruction stores to (if any)
 *   - `modes` - mode of each argument (`0`=positional, `1`=immediate)
 */
exports.decode = (program) => {
  const o = splitOpcode(program[0]);
  o.args = program.slice(1, 1 + o.argCount);
  return o;
};

// Decode the opcode portion of an instruction.
//
// This does the bulk of the work for decode(). See also "Terminology note"
// (above).
const splitOpcode = (instruction) => {
  const opcode = instruction % 100;
  const opcodeName =    {1: 'ADD', 2: 'MUL', 3: 'IN', 4: 'OUT', 5: 'JTRU', 6: 'JFAL', 7: 'LT', 8: 'EQ', 9: 'ARB', 99: 'HALT'}[opcode];
  const argCount =      {1: 3,     2: 3,     3: 1,    4: 1,     5: 2,      6: 2,      7: 3,    8: 3,    9: 1,     99: 0}[opcode];
  // which argument does the instruction store the result to (if any)?
  const storeArgIndex = {1: 2,     2: 2,     3: 0,    4: null,  5: null,   6: null,   7: 2,    8: 2,    9: null,  99: null}[opcode];
  // the mode of each argument: 0=positional(indirect) 1=immediate
  const modes = [];
  for (let i = 0, mode = 100; i < argCount; i++, mode *= 10) {
    modes[i] = Math.floor((instruction % (mode * 10)) / mode) % 10;
  }
  // "Parameters that an instruction writes to will never be in immediate mode."
  if (modes[storeArgIndex] === 1) {
    throw new Error('immediate mode is invalid for store argument');
  }
  return {opcode, opcodeName, argCount, storeArgIndex, modes};
};

/**
 * Reencode ("disassemble") an instruction to string.
 *
 * @param {object} inst - instruction object (as from `decode()`)
 *
 * @return {string}
 *   Returns an "assembler" instruction string suitable for debug output.
 */
exports.instructionString = (inst) => {
  let str = inst.opcodeName;
  for (let i = 0; i < inst.argCount; i++) {
    str += ((i > 0) ? ',' : ' ');
    if (inst.modes[i] === 2) {
      str += '*';
    } else if (inst.modes[i] !== 1) {
      str += 'M';
    }
    str += inst.args[i];
  }
  return str;
};
