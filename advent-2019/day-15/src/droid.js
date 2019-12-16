'use strict';
const intcode = require('../../shared/src/intcode');

// TODO RF this._grid, Klass._mapKey(), dump(), etc. are used by several
//      days; extract them to a generalized PuzzleGrid class, with no
//      coverage ignores (e.g. dump() returns list of lines)

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
    // private: the maze (key: position, value: 0=wall 1=open 2=oxygen)
    this._grid = new Map();
    // private: [Y, X] position of droid
    this._position = [0, 0];
    // "you already know [the starting] location is open"
    this._grid.set(Droid._mapKey(this._position), 1);
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
    /*
     * FIXME these two should be class/global, not per-instance
     */
    // private: map of directions to [dY, dX] offsets
    this._offsets = {
      1: [-1, 0],  // north
      2: [1, 0],   // south
      3: [0, -1],  // west
      4: [0, 1],   // east
    };
    // private: opposites of each direction
    this._oppositeDir = {1: 2, 2: 1, 3: 4, 4: 3};
  }
  /**
   * Set grid map.
   *
   * Used for testing `longestPathLengthFrom()` method.
   *
   * @param {object} grid - the grid map
   */
  setGrid(grid)
  {
    this._grid = grid;
    this._explored = true;
  }
  // private: choose next move
  _chooseMove()
  {
    // move in the next unexplored direction
    for (let dir = 1; dir <= 4; dir++) {
      if (this._grid.get(Droid._mapKey(this._newPosition(dir))) === undefined) {
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
    return this._oppositeDir[this._path.pop()];
  }
  // private: calculate new position from direction
  _newPosition(dir)
  {
    const y = this._position[0] + this._offsets[dir][0];
    const x = this._position[1] + this._offsets[dir][1];
    return [y, x];
  }
  // private: move in indicated direction
  _move(dir)
  {
    this._position = this._newPosition(dir);
    if (this._backtracking) {
      this._backtracking = false;
    } else {
      this._path.push(dir);
    }
  }
  // private: backtrack
  _moveBack()
  {
    const backDir = this._oppositeDir[this._path.pop()];
    this._position = this._newPosition(backDir);
  }
  /* istanbul ignore next */
  /**
   * Run the maze-running Intcode program until it halts.
   */
  run()
  {
    // IN is used by us to tell the droid what direction to attempt
    const getValue = (() => (this._lastDir = this._chooseMove()));
    // OUT is used by the droid to tell us what happened
    const storeValue = ((v) => {
      this._grid.set(Droid._mapKey(this._newPosition(this._lastDir)), v);
      if (v !== 0) {  // v=0 (hit wall) means droid didn't move
        this._move(this._lastDir);
        if (v === 2) {
          this.oxygenSystemPosition = this._position.slice();
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
   * @param {Array} position - [Y, X] start position
   *
   * @return {number}
   *   Returns the longest path length from the start position.
   */
  longestPathLengthFrom(position)
  {
    if (!this._explored) {
      throw new Error('maze must first be explored with run()');
    }
    this._position = position.slice();
    this._path = [];
    return this._longestPathLength();
  }
  // private: recursive path explorer
  _longestPathLength()
  {
    const sourceDir = this._oppositeDir[this._path[this._path.length-1]];
    let longest = 0;
    for (let dir = 1; dir <= 4; dir++) {
      // only move further out from start position, don't double back:
      if (dir === sourceDir) {
        continue;
      }
      // TODO RF this._isBlocked(dir)
      const position1 = this._newPosition(dir);
      const what = this._grid.get(Droid._mapKey(position1));
      // wall in this direction; no longest path that way:
      if (what === 0) {
        continue;
      }
      // open in this direction; recursively explore that way:
      this._move(dir);
      const longest1 = this._longestPathLength();
      this._moveBack();
      longest = Math.max(longest, longest1 + 1);
    }
    return longest;
  }
  // private: map key for a given [Y, X] position
  static _mapKey(position)
  {
    return `${position[0]},${position[1]}`;
  }
  /* istanbul ignore next */
  /**
   * Display the maze.
   */
  dump()
  {
    const squares = Array.from(this._grid.keys()).map((k) => k.split(/,/).map((str) => Number(str)));
    const squareMin = squares.reduce((mins, p) => [Math.min(p[0], mins[0]), Math.min(p[1], mins[1])], [999999, 999999]);
    const squareMax = squares.reduce((maxes, p) => [Math.max(p[0], maxes[0]), Math.max(p[1], maxes[1])], [-999999, -999999]);
    for (let y = squareMin[0]; y <= squareMax[0]; y++) {
      for (let x = squareMin[1]; x <= squareMax[1]; x++) {
        if ((y === 0) && (x === 0)) {
          process.stdout.write(':');  // origin
        } else {
          const what = this._grid.get(Droid._mapKey([y, x]));
          process.stdout.write(Droid._dumpCh(what));
        }
      }
      process.stdout.write('\n');
    }
  }
  /* istanbul ignore next */
  // private: display character for space type
  static _dumpCh(what)
  {
    return (what === 0) ? '#' : ((what === 1) ? '.' : ((what === 2) ? '@' : ' '));
  }
}
module.exports = Droid;
