'use strict';
const intcode = require('../../shared/src/intcode');

class ArcadeGame
{
  /**
   * Build a new arcade game from an input string.
   *
   * @param {string} input - the input string, an Intcode program
   *
   * @return {ArcadeGame}
   *   Returns a new ArcadeGame class object.
   */
  constructor(input)
  {
    // private: our Intcode program
    this.program = input.trim().split(/,/).map((str) => Number(str));
    // private: game tiles
    this.grid = new Map();
  }
  /**
   * Set tile at the given position.
   *
   * @param {Array} position - [Y, X] coordinates
   * @param {number} tile - tile type
   */
  setTile(position, tile)
  {
    this.grid.set(ArcadeGame._mapKey(position), tile);
  }
  /**
   * Count tiles of a given type.
   *
   * @param {number} tile - tile type
   *
   * @return {number}
   *   Returns the count of tiles.
   */
  countOf(tile)
  {
    return Array.from(this.grid.values()).filter((k) => k === tile).length;
  }
  /*
   * Run the arcade game Intcode program until it halts.
   */
  /* istanbul ignore next */
  run()
  {
    let stack = [];
    const storeValue = ((v) => {
      stack.push(v);
      if (stack.length === 3) {
        this.setTile([stack[1], stack[0]], stack[2]);
        stack = [];
      }
    });
    intcode.run(this.program, false, undefined, storeValue);
  }
  // private: map key for a given [y, x] location
  static _mapKey(position)
  {
    return `${position[0]},${position[1]}`;
  }
}
module.exports = ArcadeGame;
