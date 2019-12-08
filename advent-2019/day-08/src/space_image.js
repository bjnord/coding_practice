'use strict';
class SpaceImage
{
  constructor(string, options)
  {
    if (!options) {
      throw new Error('missing options');
    }
    if (!(this.width = options.width)) {
      throw new Error('missing width');
    }
    if (!(this.height = options.height)) {
      throw new Error('missing height');
    }
    const llen = this.width * this.height;
    this.layers = [];
    string = string.trim();
    while (string.length > 0) {
      const layer = string.slice(0, llen);
      if (!(layer.match(/^\d+$/))) {
        throw new Error('non-digit characters');
      } else if (layer.length !== llen) {
        throw new Error('last layer incomplete');
      }
      this.layers.push(layer);
      string = string.slice(llen);
    }
    this.nLayers = this.layers.length;
  }
  layerCount(n, digit)
  {
    if (this.layers[n] === undefined) {
      throw new Error(`invalid layer ${n}`);
    }
    const digits = this.layers[n].split('').filter((d) => d === digit);
    return digits.length;
  }
  render()
  {
    const llen = this.width * this.height;
    let render = '';
    for (let i = 0; i < llen; i++) {
      for (let l = 0; l < this.nLayers; l++) {
        // '2' pixels are transparent; find first opaque pixel
        if (this.layers[l][i] !== '2') {
          render += this.layers[l][i];
          break;
        }
      }
    }
    return render;
  }
  /* istanbul ignore next */
  dump()
  {
    const render = this.render();
    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
        const ch = render[y * this.width + x];
        process.stdout.write((ch === '1') ? '\u25a0' : ' ');
      }
      process.stdout.write('\n');
    }
  }
};
module.exports = SpaceImage;
