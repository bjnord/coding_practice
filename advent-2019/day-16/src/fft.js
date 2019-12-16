'use strict';
/** @module */
/**
 * Produce the FFT pattern.
 *
 * @param {number} count - number of elements
 * @param {number} index - 0-relative index of pattern (e.g. 1 = 2nd pattern)
 *
 * @return {Array}
 *   Returns an array of length `count` with the FFT pattern for the given
 *   `index`.
 */
exports.pattern = (count, index) => {
  if (count < 1) {
    throw new Error('invalid element count');
  } else if (index < 0) {
    throw new Error('invalid pattern index');
  }
  const basePattern = [0, 1, 0, -1];
  // repeat base pattern elements:
  // (e.g. for index=1 we want [0, 0, 1, 1, 0, 0, -1 -1])
  const pattern = basePattern.map((v) => Array(index+1).fill(v));
  // TODO Node v11+ has Array.prototype.flat()
  //      h/t <https://stackoverflow.com/a/10865042/291754>
  const flattened = [].concat.apply([], pattern);
  // if pattern is shorter than requested, repeat it:
  const mod = flattened.length;
  for (let i = mod; i < count; i++) {
    flattened.push(flattened[i % mod]);
  }
  // rotate pattern one position left:
  flattened.push(flattened.shift());
  // if pattern is longer than requested, trim it:
  if (mod > count) {
    for (let i = mod; i > count; i--) {
      flattened.pop();
    }
  }
  return flattened;
};
// private: list of patterns
const patternList = (count) => {
  const patterns = [];
  //console.debug('patternList:');
  for (let i = 0; i < count; i++) {
    patterns.push(module.exports.pattern(count, i));
    //console.debug(`i=${i} pattern=${patterns[i]}`);
  }
  return patterns;
};
/**
 * Do one phase of FFT.
 *
 * @param {Array} elements - input elements
 * @param {number} index - 0-relative index of phase (e.g. 1 = 2nd phase)
 *
 * @return {Array}
 *   Returns an array of length `count` with the FFT pattern for the given
 *   `index`.
 */
exports.phase = (elements, index, _patterns = undefined) => {
  if (elements.length === 0) {
    throw new Error('empty element list');
  } else if (index < 0) {
    throw new Error('invalid phase index');
  }
  const patterns = _patterns || patternList(elements.length);
  const newElements = elements.map((el, y) => {
    const cols = elements.map((el, x) => {
      return el * patterns[y][x];
    });
    //console.debug(`< row=${y} elements=${elements}`);
    //console.debug(`- row=${y}  pattern=${patterns[y]}`);
    //console.debug(`= row=${y}     cols=${cols}`);
    const sum = Math.abs(cols.reduce((sum, n) => sum + n, 0) % 10);
    //console.debug(`> row=${y}      sum=${sum}`);
    return sum;
  });
  return newElements;
};
