'use strict';
/** @module lava */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a droplet (list of cubes).
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `2,1,5`)
 *
 * @return {Object}
 *   Returns a cube.
 */
exports.parseLine = (line) => {
  const coords = line.split(',').map((coord) => parseInt(coord));
  return {z: coords[2], y: coords[1], x: coords[0]};
};

const buildMap = ((droplet, func) => {
  const map = droplet.reduce((m, cube) => {
    // 0=key of 2 dimensions, 1=3rd dimension coord
    const pair = func(cube);
    if (!m[pair[0]]) {
      m[pair[0]] = [{coord: pair[1], cube}];
    } else {
      m[pair[0]].push({coord: pair[1], cube});
    }
    return m;
  }, {});
  for (const k in map) {
    map[k] = map[k].sort((a, b) => Math.sign(a.coord - b.coord));
  }
  return map;
});

const faceOff = ((map) => {
  let diff = 0;
  for (const k in map) {
    let prevV = undefined;
    for (const v of map[k]) {
      if (prevV && (v.coord === prevV.coord + 1)) {
        diff += 2;
      }
      prevV = v;
    }
  }
  return diff;
});

exports.surfaceArea = ((droplet) => {
  const nFaces = droplet.length * 6;
  // z + y faces
  const zyFunc = ((cube) => [`${cube.z},${cube.y}`, cube.x]);
  const zyMap = buildMap(droplet, zyFunc);
  const zyDiff = faceOff(zyMap);
  // z + x faces
  const zxFunc = ((cube) => [`${cube.z},${cube.x}`, cube.y]);
  const zxMap = buildMap(droplet, zxFunc);
  const zxDiff = faceOff(zxMap);
  // y + x faces
  const yxFunc = ((cube) => [`${cube.y},${cube.x}`, cube.z]);
  const yxMap = buildMap(droplet, yxFunc);
  const yxDiff = faceOff(yxMap);
  // result
  return nFaces - zyDiff - zxDiff - yxDiff;
});
