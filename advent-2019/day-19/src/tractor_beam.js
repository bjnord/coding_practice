'use strict';
const PuzzleGrid = require('../../shared/src/puzzle_grid');
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
    // private: the affected-area grid
    this._grid = new PuzzleGrid({
      0: {name: 'stationary', render: '.'},
      1: {name: 'pulled', render: '#'},
    });
  }
  /**
   * Map every point in the grid.
   *
   * This is done by running the Intcode program with the [Y, X] position of
   * every point.
   */
  mapGrid(size)
  {
    let x = 0, y = 0, flipFlop = 0;
    const getValue = (() => {
      const send = flipFlop ? y : x;
      //console.debug(`send ${send} as ${flipFlop ? 'Y' : 'X'} for ${y}x${x}`);
      flipFlop = 1 - flipFlop;
      return send;
    });
    const storeValue = ((pulled) => {
      this._grid.set([y, x], pulled);
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
  /**
   * the number of grid points affected by tractor beam
   * @member {number}
   */
  get pointsAffected()
  {
    return this._grid.positionsWithType(1).length;
  }
}
module.exports = TractorBeam;
