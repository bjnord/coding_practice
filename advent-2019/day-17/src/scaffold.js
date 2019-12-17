'use strict';
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const intcode = require('../../shared/src/intcode');

// private: map of directions to [dY, dX] offsets
const _offsets = {
  1: [-1, 0],  // up
  2: [1, 0],   // down
  3: [0, -1],  // left
  4: [0, 1],   // right
};

// private: map of direction characters to direction
const _directions = {94: 1, 118: 2, 60: 3, 62: 4, 88: undefined};

// private: opposites of each direction
const _oppositeDir = {1: 2, 2: 1, 3: 4, 4: 3};

class Scaffold
{
  /**
   * Build a new scaffold from an input string.
   *
   * @param {string} input - the input string, an Intcode program (which
   *   will output the scaffold map)
   *
   * @return {Scaffold}
   *   Returns a new Scaffold class object.
   */
  constructor(input)
  {
    // private: our Intcode program
    this._program = input.trim().split(/,/).map((str) => Number(str));
    // private: the scaffold grid
    this._grid = new PuzzleGrid({
      0: {name: 'space', render: '.'},
      1: {name: 'scaffold', render: '#'},
      2: {name: 'intersection', render: 'O'},
    });
    // private: [Y, X] position of vacuum robot
    this._position = undefined;
    // private: direction of vacuum robot (1=up 2=down 3=left 4=right)
    this._direction = undefined;
  }
  /**
   * Run the grid-producing Intcode program until it halts.
   */
  run()
  {
    let y = 0, x = 0;
    // OUT gives us the next ASCII character
    const storeValue = ((v) => {
      switch (v) {
      case 10:  // \n (go to next line)
        y++;
        x = 0;
        break;
      case 46:  // . = outer space
        this._grid.set([y, x++], 0);
        break;
      case 35:  // # = scaffold
        this._grid.set([y, x++], 1);
        break;
      case 94:  // ^ = robot faces up
      case 118: // v = robot faces down
      case 60:  // < = robot faces left
      case 62:  // > = robot faces right
      case 88:  // X = robot is tumbling through space
        this._position = [y, x];
        this._direction = _directions[v];
        this._grid.set([y, x++], (v === 88) ? 0 : 1);
        break;
      /* istanbul ignore next */
      default:
        throw new Error(`got unknown scaffold character ${v} from Intcode program`);
      };
    });
    intcode.run(this._program, false, undefined, storeValue);
  }
}
module.exports = Scaffold;
