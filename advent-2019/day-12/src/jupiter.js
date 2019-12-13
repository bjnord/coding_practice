'use strict';
const floyd = require('../../shared/src/floyd');
const util = require('../../shared/src/util');
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input (e.g. `<x=-6, y=-5, z=-8>`) separated by `\n`
 *
 * @return {Array}
 *   Returns a list of moons, each one an object with these fields:
 *   - `z` - position and velocity on Z axis (`[Z, dZ]`)
 *   - `y` - position and velocity on Y axis (`[Y, dY]`)
 *   - `x` - position and velocity on X axis (`[X, dX]`)
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line))
    .map((coord) => ({z: [coord[0], 0], y: [coord[1], 0], x: [coord[2], 0]}));
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
 * @param {Array} moons - list of moons, each an object with axis fields
 */
exports.step = (moons) => {
  ['z', 'y', 'x'].forEach((axis) => {
    module.exports.stepAxis(moons.map((moon) => moon[axis]));
  });
};
/**
 * Run one step of moon movement along just one axis.
 *
 * @param {Array} moons - list of moons, each a [position, velocity] tuple
 */
exports.stepAxis = (moons) => {
  // Apply gravity to velocity:
  for (let i = 0; i < moons.length; i++) {
    for (let j = 0; j < moons.length; j++) {
      // we can compare a moon to itself safely, as a side-effect of this:
      // "if the positions on a given axis are the same, the velocity on
      // that axis does not change for that pair of moons"
      if (moons[i][0] < moons[j][0]) {
        moons[i][1] += 1;
      } else if (moons[i][0] > moons[j][0]) {
        moons[i][1] -= 1;
      }
    }
  }
  // Apply velocity to position:
  for (let i = 0; i < moons.length; i++) {
    moons[i][0] += moons[i][1];
  }
};
/**
 * Calculate total energy of a moon.
 *
 * @param {object} moon - moon to measure
 *
 * @return
 *   Returns total energy of the moon.
 */
exports.totalEnergy = (moon) => {
  const pot = Object.keys(moon).reduce((sum, k) => sum + Math.abs(moon[k][0]), 0);
  const kin = Object.keys(moon).reduce((sum, k) => sum + Math.abs(moon[k][1]), 0);
  //console.debug(`pos=${moon.pos} pot=${pot} vel=${moon.vel} kin=${kin}`);
  return pot * kin;
};
const axisCycleLength = (moons) => {
  // moons = [[Z1, dZ1], [Z2, dZ2], ..., [Z<n>, dZ<n>]]
  const f = (x) => {
    const xCopy = x.map((t) => t.slice());
    module.exports.stepAxis(xCopy);
    return xCopy;
  };
  const eq = (a, b) => {
    return a.every((t, i) => (t[0] === b[i][0]) && (t[1] === b[i][1]));
  };
  const lmu = floyd.run(f, eq, moons);
  /* istanbul ignore if */
  if (lmu[1] !== 0) {
    throw new Error("axisCycleLength: cycle didn't return to index 0");
  }
  return lmu[0];
};
/**
 * Calculate number of steps of moon movement before moons return to the
 * original state.
 *
 * @param {Array} moons - list of moons, each an object with axis fields
 *
 * @return
 *   Returns number of steps in the cycle.
 */
exports.cycleLength = (moons) => {
  const cycles = ['z', 'y', 'x'].map((axis) => {
    const aMoons = moons.map((moon) => moon[axis]);
    return axisCycleLength(aMoons);
  });
  return util.LCM(cycles[0], util.LCM(cycles[1], cycles[2]));
};
