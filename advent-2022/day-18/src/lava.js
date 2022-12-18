'use strict';
/** @module lava */
const _debug = false;
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
    minZ: droplet.reduce((min, cube) => (cube.z < min) ? cube.z : min, Number.MAX_SAFE_INTEGER),
    maxZ: droplet.reduce((max, cube) => (cube.z > max) ? cube.z : max, -Number.MAX_SAFE_INTEGER),
    minY: droplet.reduce((min, cube) => (cube.y < min) ? cube.y : min, Number.MAX_SAFE_INTEGER),
    maxY: droplet.reduce((max, cube) => (cube.y > max) ? cube.y : max, -Number.MAX_SAFE_INTEGER),
    minX: droplet.reduce((min, cube) => (cube.x < min) ? cube.x : min, Number.MAX_SAFE_INTEGER),
    maxX: droplet.reduce((max, cube) => (cube.x > max) ? cube.x : max, -Number.MAX_SAFE_INTEGER),
  };
});

// is `cube` within the bounds of `dim` **plus** 1 air cube plane
// on all sides?
exports.withinDroplet = ((cube, dim) => {
  const zOK = ((dim.minZ - 1) <= cube.z) && (cube.z <= (dim.maxZ + 1));
  const yOK = ((dim.minY - 1) <= cube.y) && (cube.y <= (dim.maxY + 1));
  const xOK = ((dim.minX - 1) <= cube.x) && (cube.x <= (dim.maxX + 1));
  return zOK && yOK && xOK;
});

const cubesToInput = ((cubes) => {
  let input = '';
  for (const cube of cubes) {
    input += `${cube.s}\n`;
  }
  return input;
});

const neighborCubes = ((cube) => {
  const neighbors = [
    {z: cube.z - 1, y: cube.y,     x: cube.x,     },
    {z: cube.z + 1, y: cube.y,     x: cube.x,     },
    {z: cube.z,     y: cube.y - 1, x: cube.x,     },
    {z: cube.z,     y: cube.y + 1, x: cube.x,     },
    {z: cube.z,     y: cube.y,     x: cube.x - 1, },
    {z: cube.z,     y: cube.y,     x: cube.x + 1, },
  ];
  return neighbors.map((neighbor) => {
    neighbor.s = cubeKey(neighbor);
    return neighbor;
  });
});

// worker (non-recursive)
// returns neighbor cubes that should be visited
const calcAirCube = ((cube, dim, lavaCubes, lavaFaces) => {
  const children = [];
  for (const neighbor of neighborCubes(cube)) {
    if (!module.exports.withinDroplet(neighbor, dim)) {
      // neighbor is outside the box; do nothing
    } else if (lavaCubes[neighbor.s]) {
      // neighbor is lava: add one face to my count
      if (!lavaFaces[cube.s]) {
        lavaFaces[cube.s] = 1;
      } else {
        lavaFaces[cube.s]++;
      }
    } else if (lavaFaces[neighbor.s] === undefined) {
      // neighbor is unvisited air: add to next list
      children.push(neighbor);
    }
  }
  if (lavaFaces[cube.s] === undefined) {
    lavaFaces[cube.s] = 0;
  }
  if (_debug) {
    console.log(`walked me=${cube.s} nFaces=${lavaFaces[cube.s]} nChildren=${children.length}:`);
    console.dir(cube);
    console.dir(children);
  }
  return children;
});

// walk air cubes recursively
// breadth-first search (BFS)
// includes one cube plane outside each droplet face
const walkAirCubes = ((cubes, dim, lavaCubes, lavaFaces) => {
  if (cubes.length < 1) {
    return;
  }
  let nextCubes = [];
  for (const cube of cubes) {
    const children = calcAirCube(cube, dim, lavaCubes, lavaFaces);
    // append new children to end:
    for (const child of children) {
      if (!nextCubes.find((cube) => cube.s === child.s)) {
        nextCubes.push(child);
      }
    }
  }
  if (_debug) {
    console.log(`walked current cubes; nextCubes=${nextCubes.length}:`);
    console.dir(nextCubes);
    console.log('lavaFaces:');
    console.dir(lavaFaces);
  }
  // tail recursion
  walkAirCubes(nextCubes, dim, lavaCubes, lavaFaces);
});

exports.trueSurfaceArea = ((droplet) => {
  const dim = module.exports.dropletDim(droplet);
  const lavaCubes = droplet.reduce((h, cube) => {
    h[cube.s] = cube;
    return h;
  }, {});
  if (_debug) {
    console.log(`lavaCubes[${Object.keys(lavaCubes).length}]:`)
    console.dir(lavaCubes);
  }
  // guaranteed to be an air cube:
  const rootAirCube = {
    z: dim.minZ - 1,
    y: dim.minZ - 1,
    x: dim.minZ - 1,
  };
  rootAirCube.s = cubeKey(rootAirCube);
  const lavaFaces = {};
  walkAirCubes([rootAirCube], dim, lavaCubes, lavaFaces);
  const nLavaFaces = Object.values(lavaFaces)
    .reduce((total, nFaces) => total + nFaces, 0);
  return nLavaFaces;
});
