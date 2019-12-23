'use strict';
const SaintNIC = require('../src/saint_nic');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// PART 1
const computers = new SaintNIC(input, 50);
const lastPacket = computers.routePackets();
console.log('part 1: expected answer:          24602');
console.log(`part 1: Y value from last packet: ${lastPacket.y}`);
console.log('');
