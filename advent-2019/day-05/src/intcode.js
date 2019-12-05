'use strict';
const reader = require('readline-sync');
const run = (program, debug = false) => {
  let pc = 0;
  for (;;) {
    const inst = decode(program.slice(pc, pc+4));
    /* istanbul ignore if */
    if (debug) {
      console.debug(`[PC:${pc} ${instructionString(inst)}]`);
    }
    let op0, op1;
    switch (inst.opcode) {
    case 1:  // ADD
      // TODO RF mode/op picker function
      op0 = (inst.modes[0] === 1) ? inst.args[0] : program[inst.args[0]];
      op1 = (inst.modes[1] === 1) ? inst.args[1] : program[inst.args[1]];
      program[inst.args[2]] = op0 + op1;
      break;
    case 2:  // MUL
      op0 = (inst.modes[0] === 1) ? inst.args[0] : program[inst.args[0]];
      op1 = (inst.modes[1] === 1) ? inst.args[1] : program[inst.args[1]];
      program[inst.args[2]] = op0 * op1;
      break;
    /* istanbul ignore next */
    case 3:  // IN
      op0 = reader.question('INPUT: ');
      program[inst.args[0]] = Number(op0);
      break;
    /* istanbul ignore next */
    case 4:  // OUT
      op0 = (inst.modes[0] === 1) ? inst.args[0] : program[inst.args[0]];
      console.log(op0);
      break;
    case 99:  // HALT
      break;
    default:
      throw new Error(`invalid opcode ${inst.opcode} at PC=${pc}`);
    }
    if (inst.opcode === 99) {  // HALT
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
  const argCount = ((opcode === 1) || (opcode === 2)) ? 3 : (((opcode === 3) || (opcode === 4)) ? 1 : 0);
  const modes = [];
  for (let i = 0, mode = 100; i < argCount; i++, mode *= 10) {
    if ((instruction / mode) % 10 === 1) {
      modes[i] = 1;
      instruction -= mode;
    } else {
      modes[i] = 0;
    }
  }
  return {
    opcode,
    argCount,
    modes
  };
};
const instructionString = (inst) => {
  // TODO RF move this to decoder; change run() to select by name (incl exception)
  const opcodeNames = {1: 'ADD', 2: 'MUL', 3: 'IN', 4: 'OUT', 99: 'HALT'};
  let str = opcodeNames[inst.opcode];
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
