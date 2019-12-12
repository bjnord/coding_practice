'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input (e.g. `<x=-6, y=-5, z=-8>`) separated by `\n`
 *
 * @return {Array}
 *   Returns a list of moons, each one an object with these fields:
 *   - `pos` - position of moon (`[Z, Y, X]` coordinates)
 *   - `vel` - velocity of moon (`[dZ, dY, dX]` vector)
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => ({pos: module.exports.parseLine(line), vel: [0, 0, 0]}));
};
/**
 * Parse one line of coordinates from the puzzle input.
 *
 * @param {string} line - line of puzzle input (e.g. `<x=-6, y=-5, z=-8>`)
 *
 * @return {Array}
 *   Returns a [Z, Y, X] coordinates tuple.
 */
exports.parseLine = (line) => {
  const c = line.trim().split(/=/).map((c) => parseInt(c));
  return [c[3], c[2], c[1]];
};
/**
 * Run one step of moon movement.
 *
 * Moons are objects with these fields:
 * - `pos` - position of moon (`[Z, Y, X]` coordinates)
 * - `vel` - velocity of moon (`[dZ, dY, dX]` vector)
 *
 * @param {Array} moons - list of moons
 */
exports.step = (moons) => {
  // Apply gravity to velocity:
  for (let i = 0; i < moons.length; i++) {
    for (let j = 0; j < moons.length; j++) {
      // we can compare a moon to itself safely, as a side-effect of this:
      // "if the positions on a given axis are the same, the velocity on
      // that axis does not change for that pair of moons"
      for (let x = 0; x < 3; x++) {
        if (moons[i].pos[x] < moons[j].pos[x]) {
          moons[i].vel[x] += 1;
        } else if (moons[i].pos[x] > moons[j].pos[x]) {
          moons[i].vel[x] -= 1;
        }
      }
    }
  }
  // Apply velocity to position:
  for (let i = 0; i < moons.length; i++) {
    for (let x = 0; x < 3; x++) {
      moons[i].pos[x] += moons[i].vel[x];
    }
  }
};
/**
 * Calculate total energy of a moon.
 *
 * Moon is an object with these fields:
 * - `pos` - position of moon (`[Z, Y, X]` coordinates)
 * - `vel` - velocity of moon (`[dZ, dY, dX]` vector)
 *
 * @param {object} moon - moon to measure
 *
 * @return
 *   Returns total energy of the moon.
 */
exports.totalEnergy = (moon) => {
  const pot = moon.pos.reduce((sum, x) => sum + Math.abs(x), 0);
  const kin = moon.vel.reduce((sum, x) => sum + Math.abs(x), 0);
  //console.debug(`pos=${moon.pos} pot=${pot} vel=${moon.vel} kin=${kin}`);
  return pot * kin;
};
