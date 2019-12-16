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
  const mod = flattened.length;
  if (mod < count) {
    // pattern is shorter than requested; repeat it:
    // (pattern will be rotated one position left)
    for (let i = mod; i < count+1; i++) {
      flattened.push(flattened[i % mod]);
    }
    flattened.shift();
  } else if (mod > count) {
    // pattern is longer than requested; trim it:
    // (pattern will be rotated one position left)
    flattened.shift();
    for (let i = mod-1; i > count; i--) {
      flattened.pop();
    }
  } else {
    // pattern is exatly requested size; rotate it one position left:
    flattened.push(flattened.shift());
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
 *   Returns output elements (of same size as input `elements`) after
 *   applying one phase of FFT.
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
/**
 * Do multiple phases of FFT.
 *
 * @param {Array} elements - input elements
 * @param {number} count - number of FFT phases
 *
 * @return {Array}
 *   Returns output elements (of same size as input `elements`) after
 *   applying `count` phases of FFT.
 */
exports.phases = (elements, count) => {
  if (elements.length === 0) {
    throw new Error('empty element list');
  } else if (count < 1) {
    throw new Error('invalid phase count');
  }
  const patterns = patternList(elements.length);
  for (let i = 0; i < count; i++) {
    elements = module.exports.phase(elements, i, patterns);
    //console.debug(`i=${i} new elements=${elements}`);
  }
  return elements;
};
