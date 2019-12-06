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

// PART 2
const youParentName = orbitMap.parentOf('YOU');
const santaParentName = orbitMap.parentOf('SAN');
const transferCount = orbitMap.transferCount(youParentName, santaParentName);
console.log('part 2: expected answer is:                 439');
console.log(`part 2: minimum orbital transfers required: ${transferCount}`);
