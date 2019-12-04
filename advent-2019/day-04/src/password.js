'use strict';
// Do the digits in the string only increase or stay the same?
const increases = (pass) => {
  for (let i = 0; i < pass.length-1; i++) {
    if (pass[i] > pass[i+1]) {
      return false;
    }
  }
  return true;
};
// First matcher, for Part One:
// - digits must increase or stay the same
// - there must be at least one doubled digit somewhere
const passwordMatches = (password) => {
  if (password === undefined) {
    throw new Error('Invalid argument');
  }
  const doubles = (pass) => {
    for (let i = 0; i < pass.length-1; i++) {
      if (pass[i] === pass[i+1]) {
        return true;
      }
    }
    return false;
  };
  return increases(password) && doubles(password);
};
// Second matcher, for Part Two:
// - digits must increase or stay the same
// - there must be at least one doubled digit somewhere which is NOT part
//   of a larger (3+) run of digits
const passwordMatchesToo = (password) => {
  if (password === undefined) {
    throw new Error('Invalid argument');
  }
  const doubles = (pass) => {
    for (let i = 0; i < pass.length-1; i++) {
      if ((pass[i] === pass[i+1]) && (pass[i] !== pass[i-1]) && (pass[i+1] !== pass[i+2])) {
        return true;
      }
    }
    return false;
  };
  return increases(password) && doubles(password);
};
exports.passwordMatches = passwordMatches;
exports.passwordMatchesToo = passwordMatchesToo;
