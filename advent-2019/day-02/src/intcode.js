const run = (program) => {
  let pc = 0;
  while (program[pc] != 99) {
    if (program[pc] == 1) {
      program[program[pc+3]] = program[program[pc+1]] + program[program[pc+2]]
    } else if (program[pc] == 2) {
      program[program[pc+3]] = program[program[pc+1]] * program[program[pc+2]]
    } else {
      console.error(`invalid opcode ${program[pc]} at PC=${pc}`);
      return [];
    }
    pc += 4;
  }
  return program;
};
exports.run = run;
