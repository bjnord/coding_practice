'use strict';
const Board = require('../src/board');

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
    // element 0 of each shape is the lowest row
    // TODO might not need the trailing 0s
    this._shapes = [
      // ####
      [0b1111, 0b0000, 0b0000, 0b0000],
      // .#.
      // ###
      // .#.
      [0b0100, 0b1110, 0b0100, 0b0000],
      // ..#
      // ..#
      // ###
      [0b1110, 0b0010, 0b0010, 0b0000],
      // #
      // #
      // #
      // #
      [0b1000, 0b1000, 0b1000, 0b1000],
      // ##
      // ##
      [0b1100, 0b1100, 0b0000, 0b0000],
    ];
    this._currentShape = 0;
    this._board = new Board();
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
    // TODO do the left-shift here
    return [...shape];  // copy
  }
  boardHeight()
  {
    return this._board.height();
  }
  dropNextShape()
  {
    this._board.makeSpace();
    let shape = this.nextShape().map((b) => b << 1);
    // "The rock begins falling"
    this._board.drawShape(shape, '@');
    this._board.drawBoard();
    let mergeRow = this._board.height();
    let overlap = 0;
    while (mergeRow >= 0) {
      // "Jet of gas pushes rock""
      switch (this.nextJet()) {
      case '<':
        if (shape.find((line) => line & 0b1000000) === undefined) {
          shape = shape.map((b) => b << 1);
        }
        break;
      case '>':
        if (shape.find((line) => line & 0b0000001) === undefined) {
          shape = shape.map((b) => b >> 1);
        }
        break;
      default:
        throw new SyntaxError('unknown jet');
      }
      this._board.drawShape(shape, '@');
      this._board.drawBoard();
      // "Rock falls one unit"
      if (this._board.shrink()) {
        // mergeRow is just empty space; shape can continue falling
        this._board.drawShape(shape, '@');
        this._board.drawBoard();
        mergeRow--;
      } else if (this._board.collision(mergeRow, overlap + 1, shape)) {
        // shape hit top of tower and can't fall any further
        break;
      } else {
        // shape can fall, overlapping with top of tower
        mergeRow--;
        overlap++;
        // TODO sadly the draw functions can't handle this yet
      }
    }
    // "Rock comes to rest"
    this._board.addShape(shape, overlap);
    this._board.drawBoard();
  }
}
module.exports = Tetris;
