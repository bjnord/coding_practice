'use strict';
const SpaceImage = require('../src/space_image');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const image = new SpaceImage(input, {width: 25, height: 6});

// PART 1
// range, h/t <https://stackoverflow.com/a/10050831/291754>
const range = [...Array(image.nLayers).keys()];
const minLayer = range.reduce((acc, n) => {
  const c = image.layerCount(n, '0');
  if (c < acc.zeros) {
    acc.zeros = c;
    acc.n = n;
  }
  return acc;
}, {n: -1, zeros: Number.MAX_SAFE_INTEGER});
const ones = image.layerCount(minLayer.n, '1');
const twos = image.layerCount(minLayer.n, '2');
console.log(`part 1: number of layers in image:        ${image.nLayers}`);
console.log(`part 1: layer with fewest 0 digits:       ${minLayer.n+1} (${minLayer.zeros} zeros)`);
console.log('part 1: expected answer:                  828');
console.log(`part 1: (1 digits) * (2 digits):          ${ones * twos}`);
console.log('');
