'use strict';
/** @module rocket */
exports.mass2fuel = (mass) => {
  return Math.floor(mass / 3.0) - 2;
};
exports.mass2fullfuel = (mass) => {
  let total = 0;
  for (let fuel = module.exports.mass2fuel(mass); fuel > 0; ) {
    total += fuel;
    fuel = module.exports.mass2fuel(fuel);
  }
  return total;
};
