'use strict';
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const PuzzleGridWalker = require('../../shared/src/puzzle_grid_walker');
const intcode = require('../../shared/src/intcode');

// private: map of directions to [dY, dX] offsets
const Droid_offsets = {
  1: [-1, 0],  // north
  2: [1, 0],   // south
  3: [0, -1],  // west
  4: [0, 1],   // east
};
// private: opposites of each direction
const Droid_oppositeDir = {1: 2, 2: 1, 3: 4, 4: 3};

class Droid
{
  /**
   * Build a new repair droid from an input string.
   *
   * @param {string} input - the input string, an Intcode program (which
   *   "you can use to remotely control the repair droid")
   *
   * @return {Droid}
   *   Returns a new Droid class object.
   */
  constructor(input)
  {
    // private: our Intcode program
    this._program = input.trim().split(/,/).map((str) => Number(str));
    // private: the maze key
    this._grid_key = {
      0: {name: 'wall', render: '#', passable: false},
      1: {name: 'open', render: '.', passable: true},
      2: {name: 'oxygen', render: '@', passable: true},
    };
    // private: the maze
    this._grid = new PuzzleGrid(this._grid_key);
    // private: [Y, X] position of droid
    this._pos = [0, 0];
    // "you already know [the starting] location is open"
    this._grid.set(this._pos, 1);
    // private: path of moves from origin (directions)
    this._path = [];
    /**
     * distance from origin to oxygen system
     * @member {number}
     */
    this.oxygenSystemDistance = undefined;
    /**
     * [Y, X] position of oxygen system
     * @member {Array}
     */
    this.oxygenSystemPosition = undefined;
    // private: last move attempt direction
    this._lastDir = undefined;
    // private: was last move a backtrack?
    this._backtracking = false;
    // private: has whole maze been explored?
    this._explored = false;
  }
  // private: choose next move
  _chooseMove()
  {
    // move in the next unexplored direction
    for (let dir = 1; dir <= 4; dir++) {
      if (this._grid.get(this._newPosition(dir)) === undefined) {
        return dir;
      }
    }
    // the whole maze has now been explored; force Intcode machine to halt
    if (this._path.length === 0) {
      this._explored = true;
      return undefined;
    }
    // all directions from this position have been explored; backtrack
    this._backtracking = true;
    return Droid_oppositeDir[this._path.pop()];
  }
  // private: calculate new position from direction
  _newPosition(dir)
  {
    const y = this._pos[0] + Droid_offsets[dir][0];
    const x = this._pos[1] + Droid_offsets[dir][1];
    return [y, x];
  }
  // private: move in indicated direction
  _move(dir)
  {
    this._pos = this._newPosition(dir);
    if (this._backtracking) {
      this._backtracking = false;
    } else {
      this._path.push(dir);
    }
  }
  /**
   * Run the maze-running Intcode program until it halts.
   */
  run()
  {
    // IN is used by us to tell the droid what direction to attempt
    const getValue = (() => (this._lastDir = this._chooseMove()));
    // OUT is used by the droid to tell us what happened
    const storeValue = ((v) => {
      this._grid.set(this._newPosition(this._lastDir), v);
      if (v !== 0) {  // v=0 (hit wall) means droid didn't move
        this._move(this._lastDir);
        if (v === 2) {
          this.oxygenSystemPosition = this._pos.slice();
          this.oxygenSystemDistance = this._path.length;
        }
      }
      this._lastDir = undefined;
    });
    intcode.run(this._program, false, getValue, storeValue);
  }
  /**
   * Explore the maze from a given position to find the longest path length.
   *
   * @param {Array} pos - [Y, X] start position
   *
   * @return {number}
   *   Returns the longest path length from the start position.
   */
  longestPathLengthFrom(pos)
  {
    if (!this._explored) {
      throw new Error('maze must first be explored with run()');
    }
    let longestPathLength = 0;
    // use destructuring to avoid lint "unused argument" errors
    // h/t <https://stackoverflow.com/a/58738236/291754>
    const movedTo = (...[, , steps]) => {
      longestPathLength = Math.max(longestPathLength, steps);
    };
    const walker = new PuzzleGridWalker(this._grid);
    walker.walk(pos, {
      'movedTo': movedTo,
    });
    return longestPathLength;
  }
}
module.exports = Droid;
