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

const cubeKey = ((cube) => `${cube.x},${cube.y},${cube.z}`);
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
  const cube = {z: coords[2], y: coords[1], x: coords[0]};
  cube.s = cubeKey(cube);
  return cube;
};

const dumpPlane = ((lavaCubes, dim, z) => {
  console.log(`[[ ---- z=${z} ---- ]]`);
  for (let y = dim.maxY; y >= dim.minY; y--) {
    let line = '';
    for (let x = dim.minX; x <= dim.maxX; x++) {
      if (lavaCubes[cubeKey({z, y, x})]) {
        line += '#';
      } else {
        line += '.';
      }
    }
    console.log(line);
  }
  console.log('');
});

exports.dump = ((droplet) => {
  const dim = module.exports.dropletDim(droplet);
  const lavaCubes = droplet.reduce((h, cube) => {
    h[cube.s] = cube;
    return h;
  }, {});
  console.log('droplet dimensions:');
  console.dir(dim);
  console.log('');
  for (let z = dim.minZ; z <= dim.maxZ; z++) {
    dumpPlane(lavaCubes, dim, z);
  }
});

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

exports.simpleSurfaceArea = ((droplet) => {
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

const interiorCubes = ((map, dim) => {
  const cubes = [];
  for (const k in map) {
    let prevV = undefined;
    for (const v of map[k]) {
      if (prevV && (v.coord > prevV.coord + 1)) {
        for (let i = prevV.coord + 1; i < v.coord; i++) {
          let cube;
          switch (dim) {
          case 'z':
            cube = {z: i, y: v.cube.y, x: v.cube.x};
            break;
          case 'y':
            cube = {z: v.cube.z, y: i, x: v.cube.x};
            break;
          case 'x':
            cube = {z: v.cube.z, y: v.cube.y, x: i};
            break;
          }
          cube.s = cubeKey(cube);
          cubes.push(cube);
        }
      }
      prevV = v;
    }
  }
  return cubes;
});

exports.dropletDim = ((droplet) => {
  return {
    minZ: droplet.reduce((min, cube) => (cube.z < min) ? cube.z : min, 999999999),
    maxZ: droplet.reduce((max, cube) => (cube.z > max) ? cube.z : max, -999999999),
    minY: droplet.reduce((min, cube) => (cube.y < min) ? cube.y : min, 999999999),
    maxY: droplet.reduce((max, cube) => (cube.y > max) ? cube.y : max, -999999999),
    minX: droplet.reduce((min, cube) => (cube.x < min) ? cube.x : min, 999999999),
    maxX: droplet.reduce((max, cube) => (cube.x > max) ? cube.x : max, -999999999),
  };
});

const cubesToInput = ((cubes) => {
  let input = '';
  for (const cube of cubes) {
    input += `${cube.s}\n`;
  }
  return input;
});

exports.trueSurfaceArea = ((droplet) => {
  // z + y faces
  const zyFunc = ((cube) => [`${cube.z},${cube.y}`, cube.x]);
  const zyMap = buildMap(droplet, zyFunc);
  const zyIntCubes = interiorCubes(zyMap, 'x');
  //console.log('zy:');
  //for (const cube of zyIntCubes) {
  //  console.dir(cube);
  //}
  // z + x faces
  const zxFunc = ((cube) => [`${cube.z},${cube.x}`, cube.y]);
  const zxMap = buildMap(droplet, zxFunc);
  const zxIntCubes = interiorCubes(zxMap, 'y');
  //console.log('zx:');
  //for (const cube of zxIntCubes) {
  //  console.dir(cube);
  //}
  const cubeEq = ((a, b) => (a.z === b.z) && (a.y === b.y) && (a.x === b.x));
  let intersectCubes = zxIntCubes.filter((a) => zyIntCubes.find((b) => cubeEq(a, b)));
  // y + x faces
  const yxFunc = ((cube) => [`${cube.y},${cube.x}`, cube.z]);
  const yxMap = buildMap(droplet, yxFunc);
  const yxIntCubes = interiorCubes(yxMap, 'z');
  //console.log('yx:');
  //for (const cube of yxIntCubes) {
  //  console.dir(cube);
  //}
  intersectCubes = yxIntCubes.filter((a) => intersectCubes.find((b) => cubeEq(a, b)));
  //console.log('intersection:');
  //for (const cube of intersectCubes) {
  //  console.dir(cube);
  //}
  const interiorInput = cubesToInput(intersectCubes);
  //console.log('interiorInput:');
  //console.log(interiorInput);
  const interiorDroplet = module.exports.parse(interiorInput);
  //console.log('interiorDroplet:');
  //console.dir(interiorDroplet);
  // result
  const extArea = module.exports.simpleSurfaceArea(droplet);
  const intArea = (intersectCubes.length > 0) ? module.exports.trueSurfaceArea(interiorDroplet) : 0;
  return extArea - intArea;
});
