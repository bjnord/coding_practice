var password = require('../src/password');
const input = '240920-789857'.split(/-/).map((n) => Number(n));

// PART 1
var matches = 0;
for (var i = input[0], matches = 0; i <= input[1]; i++) {
  if (password.passwordMatches(i.toString())) {
    matches++;
  }
}
console.log('part 1: expected answer is: 1154');
console.log(`part 1: count of matches:   ${matches}`);
console.log('');

// PART 2
matches = 0;
for (var i = input[0], matches = 0; i <= input[1]; i++) {
  if (password.passwordMatchesToo(i.toString())) {
    matches++;
  }
}
console.log('part 2: expected answer is: 750');
console.log(`part 2: count of matches:   ${matches}`);
