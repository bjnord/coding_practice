'use strict';
const intcode = require('../src/intcode');

console.log('I/O TESTS ==============================');
console.log('');
console.log('1. IN+OUT - should output the value entered');
intcode.run([3,5,4,5,99,-1]);
console.log('');
console.log('2. OUT immediate - should output "97"');
intcode.run([104,97,99]);
console.log('');

// the rest of these tests come out of the puzzle description:

console.log('COMPARISON TESTS =======================');
console.log('');
console.log('1. EQ 8 (position mode) - is the value entered equal to 8?');
intcode.run([3,9,8,9,10,9,4,9,99,-1,8]);
console.log('');
console.log('2. LT 8 (position mode) - is the value entered less than 8?');
intcode.run([3,9,7,9,10,9,4,9,99,-1,8]);
console.log('');
console.log('3. EQ 8 (immediate mode) - is the value entered equal to 8?');
intcode.run([3,3,1108,-1,8,3,4,3,99]);
console.log('');
console.log('4. LT 8 (immediate mode) - is the value entered less than 8?');
intcode.run([3,3,1107,-1,8,3,4,3,99]);
console.log('');

console.log('JUMP TESTS =============================');
console.log('');
console.log('1. JFAL (position mode) - should output "0" if 0 is entered, else "1"');
intcode.run([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]);
console.log('');
console.log('2. JTRU (immediate mode) - should output "0" if 0 is entered, else "1"');
intcode.run([3,3,1105,-1,9,1101,0,0,12,4,12,99,1]);
console.log('');
console.log('3. big combo test - "999" if input is < 8, "1000" if == 8, "1001" if > 8');
intcode.run([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]);
console.log('');
