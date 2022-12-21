'use strict';
const yell = require('../src/yell');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const monkeys = yell.parse(input);
const monkeyNumbers = yell.monkeyNumbers(monkeys);

// PART 1
console.log('part 1: expected answer:                331120084396440');
console.log(`part 1: number that root monkey yells:  ${monkeyNumbers['root']}`);
console.log('');

// PART 2
const answer2 = yell.humanYell(monkeys, monkeyNumbers);
console.log('part 2: expected answer:                3378273370680');
console.log(`part 2: actual answer:                  ${answer2}`);
console.log('');
