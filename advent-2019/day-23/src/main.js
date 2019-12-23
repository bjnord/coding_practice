'use strict';
const SaintNIC = require('../src/saint_nic');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
let computers = new SaintNIC(input, 50);
let lastPacket = computers.routePackets();
console.log('part 1: expected answer:          24602');
console.log(`part 1: Y value from last packet: ${lastPacket.y}`);
console.log('');

// PART 2
computers = new SaintNIC(input, 50);
lastPacket = computers.routePackets(true);
console.log('part 2: expected answer:          19641');
console.log(`part 2: Y value from last packet: ${lastPacket.y}`);
console.log('');
