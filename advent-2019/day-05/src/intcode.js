'use strict';
const reader = require('readline-sync');
const getOperands = (program, inst) => {
  return inst.modes.map((mode, i) => (mode === 1) ? inst.args[i] : program[inst.args[i]]);
};
const run = (program, debug = false) => {
  let pc = 0;
  for (;;) {
    const inst = decode(program.slice(pc, pc+4));
    /* istanbul ignore if */
    if (debug) {
      console.debug(`[PC:${pc} ${instructionString(inst)}]`);
    }
    const op = getOperands(program, inst);
    switch (inst.opcodeName) {
    case 'ADD':
      program[inst.args[2]] = op[0] + op[1];
      break;
    case 'MUL':
      program[inst.args[2]] = op[0] * op[1];
      break;
    /* istanbul ignore next */
    case 'IN':
      program[inst.args[0]] = Number(reader.question('INPUT: '));
      break;
    /* istanbul ignore next */
    case 'OUT':
      console.log(op[0]);
      break;
    case 'HALT':
      break;
    default:
      throw new Error(`invalid opcode ${inst.opcode} at PC=${pc}`);
    }
    if (inst.opcodeName === 'HALT') {
      break;
    }
    pc += (inst.argCount + 1);
  }
  return program;
};
// TODO set "outputArg" attribute (2 for ADD/MUL, 0 for IN, null for others)
// (to be used for the exception, below)
const splitOpcode = (instruction) => {
  const opcode = instruction % 100;
  instruction -= opcode;
  const opcodeName = {1: 'ADD', 2: 'MUL', 3: 'IN', 4: 'OUT', 99: 'HALT'}[opcode];
  const argCount =   {1: 3,     2: 3,     3: 1,    4: 1,     99: 0}[opcode];
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
