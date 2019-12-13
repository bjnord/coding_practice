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
    if (tile === 4) {
      // private: ball X coordinate
      this.ballX = position[1];
    }
    if (tile === 3) {
      // private: paddle X coordinate
      this.paddleX = position[1];
    }
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
   * Insert quarters into the arcade game.
   */
  /* istanbul ignore next */
  insertQuarters()
  {
    this.program[0] = 2;
  }
  /*
   * Run the arcade game Intcode program until it halts.
   */
  /* istanbul ignore next */
  run()
  {
    let stack = [];
    const getValue = (() => {
      if (this.ballX < this.paddleX) {
        return -1;  // tilt joystick left
      } else if (this.ballX > this.paddleX) {
        return 1;  // tilt joystick right
      } else {
        return 0;  // release joystick to neutral
      }
    });
    const storeValue = ((v) => {
      stack.push(v);
      if (stack.length === 3) {
        if (stack[0] < 0) {
          this.score = stack[2];
        } else {
          this.setTile([stack[1], stack[0]], stack[2]);
        }
        stack = [];
      }
    });
    intcode.run(this.program, false, getValue, storeValue);
  }
  // private: map key for a given [y, x] location
  static _mapKey(position)
  {
    return `${position[0]},${position[1]}`;
  }
}
module.exports = ArcadeGame;
