'use strict';
const run = (program) => {
  let pc = 0;
  while (program[pc] !== 99) {
    if (program[pc] === 1) {
      program[program[pc+3]] = program[program[pc+1]] + program[program[pc+2]];
    } else if (program[pc] === 2) {
      program[program[pc+3]] = program[program[pc+1]] * program[program[pc+2]];
    } else {
      throw new Error(`invalid opcode ${program[pc]} at PC=${pc}`);
    }
    pc += 4;
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
// TODO throw an exception if mode violates this:
// "Parameters that an instruction writes to will never be in immediate mode."
const decode = (program) => {
  const o = splitOpcode(program[0]);
  o.args = program.slice(1, 1 + o.argCount);
  return o;
};
exports.run = run;
exports.decode = decode;
