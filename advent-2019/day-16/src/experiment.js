'use strict';
const fft = require('../src/fft');

// I freely admit I have no idea how this works, mathematically. :)
//
// But from empirical observation of the 1st phase output it appears:
// - the last 4N digits of any 4N-length repeated pattern
// - will be the same no matter how many times the pattern is repeated
// - as long as it's repeated at least once
//
// "Any sufficiently advanced mathematics is indistinguishable from
// magic."
//
// I also note the following: The message offset is significantly close
// to the end of the repeated pattern. This makes me think I'm on the
// right track.
//
// $ cut -c1-7 input/input.txt
// 5975589
// $ wc input/input.txt
//   1   1 651 input/input.txt
// $ expr 650 \* 10000
// 6500000

// Suppose our input is 32 digits, and we must repeat it N times, and we
// must pick up the 8 digits at offset O:
//
//                              O
//                              <-->
// +--------+--------+- ... --+--------+- ... --+--------+
// + rep 0  | rep 1  |  ...   | rep i  |  ...   | rep N-1|
// +--------+--------+- ... --+--------+- ... --+--------+
//
// The magic says the **final 32 digits** will be the same as if we did
// this:
//
// +--------+--------+
// + rep 0  | rep 1  |
// +--------+--------+
//
// But the final 32 digits aren't enough; we need the final D*32 digits,
// where D is the smallest size that encompasses the 8 digits at O and
// divides evenly into N. So D = mrep multiple, Y = number of mreps,
// (D * Y) = N and thus D = N / Y.
//
//                                        O
//                                        <->
// +-----------+-----------+--- ... ---+-----------+
// + mrep 0    | mrep 1    |    ...    | mrep Y-1  |
// +-----------+-----------+--- ... ---+-----------+
//
// ALGORITHM
//
// 1. Define mrep size MS = size of input (e.g. 32 digits).
// 2. Start with Y = N such that D = 1.
// 3. Find beginning of "mrep Y-1" as Yedge = (Y-1) * D * MS
// 4. If O < Yedge
//    a. Y /= 2, and if that doesn't divide evenly, we fail
//    b. D *= 2
//    c. Go back to step 3.
// [Now we have the final mrep Y-1 encompassing O.]
// 5. Compute Orem = O - Yedge
// [function: (MS, N, O) => (D, Orem)]
// 6. Create FFT input by repeating the input D * 2 times
//    (each drep is length D * MS -- we need to run two dreps)
// 7. Call FFT for the 100 phase rounds.
// 8. Take 8 digits from the last D * MS digits in the output,
//    starting at Orem.

const patternList = (count) => {
  const patterns = [];
  //console.debug('patternList:');
  for (let i = 0; i < count; i++) {
    patterns.push(fft.pattern(count, i));
    //console.debug(`i=${i} pattern=${patterns[i]}`);
  }
  return patterns;
};

const phase = (elements, index, last = 4) => {
  const patterns = patternList(elements.length);
  const lastY = elements.length - last;
  const newElements = elements.map((el, y) => {
    //let s = '';
    const cols = elements.map((el, x) => {
      //if (x > 0) {
      //  s += ' +';
      //}
      //s += `${(' ' + el).slice(-2)}*${('' + patterns[y][x] + ' ').slice(0, 2)}`;
      return el * patterns[y][x];
    });
    const sum = cols.reduce((sum, n) => sum + n, 0);
    const digit = Math.abs(sum) % 10;
    //s += ` = ${digit} (${sum})`;
    if (y >= lastY) {
      //console.debug(s);  // full string
      //console.debug(` = ${digit} (${sum})`);  // only sums
    }
    return digit;
  });
  return newElements;
};

const phases = (elements, count, last = 4) => {
  for (let i = 0; i < count; i++) {
    elements = phase(elements, i, last);
  }
  return elements;
};

const nPhases = 240;

console.debug('== PATTERN OF 4 ==');
console.debug('');
console.debug('not repeated:');
let out = phases([1, 2, 3, 4], nPhases, 4);
console.debug(`last 4: ${out.slice(-4)}`);
console.debug('2x:');
out = phases([1, 2, 3, 4, 1, 2, 3, 4], nPhases, 4);
console.debug(`last 4: ${out.slice(-4)}`);
console.debug('3x:');
out = phases([1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4], nPhases, 4);
console.debug(`last 4: ${out.slice(-4)}`);
console.debug('4x:');
out = phases([1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4], nPhases, 4);
console.debug(`last 4: ${out.slice(-4)}`);
console.debug('5x:');
out = phases([1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4], nPhases, 4);
console.debug(`last 4: ${out.slice(-4)}`);
console.debug('');

console.debug('== PATTERN OF 8 ==');
console.debug('');
console.debug('not repeated:');
out = phases([1, 2, 3, 4, 5, 6, 7, 8], nPhases, 8);
console.debug(`last 8: ${out.slice(-8)}`);
console.debug('2x:');
out = phases([1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8], nPhases, 8);
console.debug(`last 8: ${out.slice(-8)}`);
console.debug('12x:');
out = phases([1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8], nPhases, 8);
console.debug(`last 8: ${out.slice(-8)}`);
console.debug('');

console.debug('== PATTERN OF 12 ==');
console.debug('');
console.debug('not repeated:');
out = phases([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9], nPhases, 12);
console.debug(`last 12: ${out.slice(-12)}`);
console.debug('2x:');
out = phases([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9], nPhases, 12);
console.debug(`last 12: ${out.slice(-12)}`);
console.debug('12x:');
out = phases([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9], nPhases, 12);
console.debug(`last 12: ${out.slice(-12)}`);
console.debug('13x:');
out = phases([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 5, 9], nPhases, 12);
console.debug(`last 12: ${out.slice(-12)}`);
console.debug('');
