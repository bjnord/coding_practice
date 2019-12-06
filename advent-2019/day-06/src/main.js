'use strict';
const OrbitMap = require('../src/orbit_map');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const orbitMap = new OrbitMap(input);

// PART 1
const totalOrbitCount = orbitMap.totalOrbitCount;
console.log('part 1: expected answer is:               314702');
console.log(`part 1: total direct and indirect orbits: ${totalOrbitCount}`);
console.log('');
