'use strict';

class Tetris
{
  /**
   * Parse the puzzle input.
   *
   * @param {string} input - lines of puzzle input separated by `\n`
   *
   * @return {Array.Object}
   *   Returns a list of [TBP].
   */
  constructor(input)
  {
    this._jets = input.trim().split('');
    this._currentJet = 0;
    this._shapes = [
      // ####
      [0b0000, 0b0000, 0b0000, 0b1111],
      // .#.
      // ###
      // .#.
      [0b0000, 0b0100, 0b1110, 0b0100],
      // ..#
      // ..#
      // ###
      [0b0000, 0b0010, 0b0010, 0b1110],
      // #
      // #
      // #
      // #
      [0b1000, 0b1000, 0b1000, 0b1000],
      // ##
      // ##
      [0b0000, 0b0000, 0b1100, 0b1100],
    ];
    this._currentShape = 0;
  };
  nextJet()
  {
    const jet = this._jets[this._currentJet];
    this._currentJet += 1;
    this._currentJet %= this._jets.length;
    return jet;
  }
  nextShape()
  {
    const shape = this._shapes[this._currentShape];
    this._currentShape += 1;
    this._currentShape %= this._shapes.length;
    return [...shape];  // copy
  }
}
module.exports = Tetris;
