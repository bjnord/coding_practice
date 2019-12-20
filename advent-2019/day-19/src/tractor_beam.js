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
   *
   * @param {number} height - the height (Y) of the grid
   * @param {number} width - the width (X) of the grid
   */
  mapGrid(height, width)
  {
    // TODO RF rewrite this to use checkPoint() method
    //      (but see note there about performance)
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
      if (++x >= width) {
        x = 0;
        if (++y >= height) {
          break;
        }
      }
    }
  }
  /**
   * Check a point in the grid.
   *
   * @param {Array} pos - the [Y, X] position to check
   *
   * @return {number}
   *   Returns `0` if the point is stationary, `1` if it's being pulled.
   */
  checkPoint(pos)
  {
    let result;
    if ((result = this._grid.get(pos))) {
      return result;
    }
    let flipFlop = 0;
    // TODO OPTIMIZE setting up these functions every time is probably slow
    const getValue = (() => {
      const send = flipFlop ? pos[0] : pos[1];
      //console.debug(`send ${send} as ${flipFlop ? 'Y' : 'X'} for [${pos}]`);
      flipFlop = 1 - flipFlop;
      return send;
    });
    const storeValue = ((pulled) => {
      this._grid.set(pos, pulled);
      result = pulled;
    });
    intcode.run(this._program.slice(), false, getValue, storeValue);
    return result;
  }
  /**
   * the number of grid points affected by tractor beam
   * @member {number}
   */
  get pointsAffected()
  {
    return this._grid.positionsWithType(1).length;
  }
  /**
   * Find the closest location at which a square box fits within the tractor
   * beam.
   *
   * @param {number} size - box size
   *
   * @return {Array}
   *   Returns [Y, X] position of upper-left corner of the box.
   */
  closestBoxPosition(size)
  {
    let lowerLeft = [size-1, 0], upperRight = [0, size-1];
    for (;;) {
      while (this.checkPoint(lowerLeft) === 0) {
        //console.debug(`lower-left @ ${lowerLeft} in space; sliding right`);
        lowerLeft[1]++;
        upperRight[1]++;
      }
      while (this.checkPoint(upperRight) === 0) {
        //console.debug(`upper-right @ ${upperRight} in space; sliding down`);
        lowerLeft[0]++;
        upperRight[0]++;
      }
      if ((this.checkPoint(lowerLeft) === 1) && (this.checkPoint(upperRight) === 1)) {
        //console.debug(`SUCCESS :: lower-left @ ${lowerLeft} :: upper-right @ ${upperRight}`);
        return [upperRight[0], lowerLeft[1]];
      } else if ((this.checkPoint(lowerLeft) !== 0) && (this.checkPoint(upperRight) !== 0)) {
        //console.debug(`FAIL :: lower-left @ ${lowerLeft} = ${this.checkPoint(lowerLeft)} :: upper-right @ ${upperRight} = ${this.checkPoint(upperRight)}`);
        throw new Error('something went wrong');
      }
    }
  }
}
module.exports = TractorBeam;
