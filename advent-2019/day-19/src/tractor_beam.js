'use strict';
const intcode = require('../../shared/src/intcode');

class TractorBeam
{
  /**
   * Build a new tractor beam from an input string.
   *
   * @param {string} input - the input string, an Intcode program
   *
   * @return {TractorBeam}
   *   Returns a new TractorBeam class object.
   */
  constructor(input)
  {
    // private: our Intcode program
    this._program = input.trim().split(/,/).map((str) => Number(str));
  }
  /**
   * Run the Intcode program until it halts.
   */
  run(size)
  {
    let x = 0, y = 0, flipFlop = 0;
    this.squaresAffected = 0;
    const getValue = (() => {
      const send = flipFlop ? y : x;
      //console.debug(`send ${send} as ${flipFlop ? 'Y' : 'X'} for ${y}x${x}`);
      flipFlop = 1 - flipFlop;
      return send;
    });
    const storeValue = ((pulled) => {
      if (pulled) {
        this.squaresAffected++;
      }
    });
    for (;;) {
      intcode.run(this._program.slice(), false, getValue, storeValue);
      if (++x >= size) {
        x = 0;
        if (++y >= size) {
          break;
        }
      }
    }
  }
}
module.exports = TractorBeam;
