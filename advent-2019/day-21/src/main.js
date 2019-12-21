'use strict';
const Hull = require('../src/hull');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');

// .................
// .................
// .@...............
// ##ABCD###########
//
//     +-----+-----+-----+-----+-----+
//     |  A  |  B  |  C  |  D  |  J  |
//     +-----+-----+-----+-----+-----+
//     |  .  |  .  |  .  |  .  |  1  | must jump (but screwed)
//     |  .  |  .  |  .  |  #  |  1  | must jump
//     |  .  |  .  |  #  |  .  |  1  | must jump (but screwed)
//     |  .  |  .  |  #  |  #  |  1  | must jump
//     |  .  |  #  |  .  |  .  |  1  | must jump (but screwed)
//     |  .  |  #  |  .  |  #  |  1  | must jump
//     |  .  |  #  |  #  |  .  |  1  | must jump (but screwed)
//     |  .  |  #  |  #  |  #  |  1  | must jump
//     |  #  |  .  |  .  |  .  |  0  | not safe to jump (might be screwed)
//     |  #  |  .  |  .  |  #  |  1  | don't risk E being a hole
//     |  #  |  .  |  #  |  .  |  0  | not safe to jump (might be screwed)
//     |  #  |  .  |  #  |  #  |  1  | don't risk E being a hole
//     |  #  |  #  |  .  |  .  |  0  | not safe to jump / walk and assess E
//     |  #  |  #  |  .  |  #  |  1  | safe to jump (possible to walk also)
//     |  #  |  #  |  #  |  .  |  0  | not safe to jump / walk and assess E
//     |  #  |  #  |  #  |  #  |  0  | no holes seen yet: keep walkin'
//     +-----+-----+-----+-----+-----+
//
//      J = !A | (D & !(B & C))
//        OR B J   // B -> J        [since J=0 initially]
//        AND C J  // (B & C) -> J
//        NOT J J  // !(B & C) -> J
//        AND D J  // (D & !(B & C)) -> J
//        NOT A T  // !A -> T
//        OR T J   // !A | (D & !(B & C)) -> J

// PART 1
const hull = new Hull(input);
const script = 'OR B J\nAND C J\nNOT J J\nAND D J\nNOT A T\nOR T J\nWALK\n';
hull.run(script);
console.log('part 1: expected answer:       19362259');
console.log(`part 1: amount of hull damage: ${hull.damage}`);
console.log('');
