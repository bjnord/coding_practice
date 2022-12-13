'use strict';
const signal = require('../src/signal');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const pairs = signal.parse(input);

// PART 1
const answer1 = signal.comparePairs(pairs)
  .map((cmp, i) => (cmp === -1) ? (i + 1) : 0)
  .reduce((sum, idx) => sum + idx, 0);
console.log('part 1: expected answer:                4734');
console.log(`part 1: actual answer:                  ${answer1}`);
console.log('');

// PART 2
const packets = signal.sortPackets(pairs);
const divider2 = packets.findIndex((packet) => signal.isDividerPacket(packet, 2)) + 1;
const divider6 = packets.findIndex((packet) => signal.isDividerPacket(packet, 6)) + 1;
console.log('part 2: expected answer:                21836');
console.log(`part 2: actual answer:                  ${divider2 * divider6}`);
console.log('');
