'use strict';
const jupiter = require('../src/jupiter');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const system = jupiter.parse(input);
for (let i = 0; i < 1000; i++) {
  jupiter.step(system);
}
const totalSystemEnergy = system.reduce((sum, moon) => sum + jupiter.totalEnergy(moon), 0);
console.log('part 1: expected answer:               5937');
console.log(`part 1: total energy after 1000 steps: ${totalSystemEnergy}`);
console.log('');
