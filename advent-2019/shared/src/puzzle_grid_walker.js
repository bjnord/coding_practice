'use strict';

// private: map of directions to [dY, dX] offsets
const PuzzleGridWalker_offsets = {
  1: [-1, 0],  // north
  2: [1, 0],   // south
  3: [0, -1],  // west
  4: [0, 1],   // east
};
// private: opposites of each direction
const PuzzleGridWalker_oppositeDir = {1: 2, 2: 1, 3: 4, 4: 3};

class PuzzleGridWalker
{
  /**
   * Build a walker by "wrapping" a puzzle grid.
   *
   * This class will not alter the contents of the `PuzzleGrid`; it treats
   * it as a read-only reference.
   *
   * @param {PuzzleGrid} grid - the puzzle grid to walk
   *
   * @return {PuzzleGridWalker}
   *   Returns a new PuzzleGridWalker class object.
   */
  constructor(grid)
  {
    // private: the puzzle grid to walk
    this._grid = grid;
    // private: current [Y, X] position
    this._pos = undefined;
    // private: stack of [Y, X] positions from origin to here
    this._path = [];
    // private: stack of direction moves from origin to here
    this._dirs = [];
    // private: number of steps from origin to here
    this._steps = undefined;
  }
  /**
   * Walk to all positions in the puzzle grid.
   *
   * All interaction while walking is accomplished via one or more
   * user-provided callback functions. At least one must be provided,
   * but any the caller does not need may be omitted. The supported
   * callbacks are:
   *
   * - `isPassable`: will be called with `(newPos, pos, path, steps)`
   *     _before_ moving to a new position - is only called for positions
   *     whose contents do not have a `passable` attribute in the puzzle
   *     grid `key` - is expected to return `true` if `newPos` is passable
   *     from the current position (`pos`), or `false` otherwise
   * - `movedTo`: will be called with `(pos, path, steps)` after moving to
   *     a new position (including once for the start position)
   *
   * @param {Array} origin - the [Y, X] start position
   * @param {object} callbacks - callbacks, in the form `{'callbackName': function, ...}`
   */
  walk(origin, callbacks)
  {
    if (!callbacks || (Object.keys(callbacks) < 1)) {
      throw new Error('at least one callback must be provided');
    }
    this._callbacks = callbacks;
    if (!this._isPassable(origin)) {
      throw new Error('origin is impassable');
    }
    this._pos = origin.slice();
    this._path = [origin.slice()];
    this._dirs = [];
    this._steps = 0;
    if (this._callbacks['movedTo']) {
      this._callbacks['movedTo'](this._pos, this._path, this._steps);
    }
    return this._walkOn();
  }
  // private: is the given position passable?
  _isPassable(pos)
  {
    let passable;
    if ((passable = this._grid.getAttr(pos, 'passable')) !== undefined) {
      return passable === true;
    } else if (this._callbacks['isPassable']) {
      return this._callbacks['isPassable'](pos, this._pos, this._path, this._steps);
    } else {
      throw new Error("can't determine passability"+` of ${this._grid.get(pos)} at ${pos}`);
    }
  }
  // private: recursive path explorer
  _walkOn()
  {
    const sourceDir = PuzzleGridWalker_oppositeDir[this._dirs[this._dirs.length-1]];
    // TODO walk forward ourself as long as only one path is open
    //      only recurse at intersections (to keep call stack shorter)
    for (let dir = 1; dir <= 4; dir++) {
      // only move further out from start position, don't double back:
      if (dir === sourceDir) {
        continue;
      }
      // this direction is impassable; no route that way:
      if (this._isBlocked(dir)) {
        continue;
      }
      // this direction is passable; recursively explore that way:
      this._move(dir);
      if (this._callbacks['movedTo']) {
        this._callbacks['movedTo'](this._pos, this._path, this._steps);
      }
      this._walkOn();
      this._moveBack();
    }
  }
  // private: compute new position from a direction
  _newPosition(dir)
  {
    const y = this._pos[0] + PuzzleGridWalker_offsets[dir][0];
    const x = this._pos[1] + PuzzleGridWalker_offsets[dir][1];
    return [y, x];
  }
  // private: move in indicated direction
  _move(dir)
  {
    this._pos = this._newPosition(dir);
    this._path.push(this._pos);
    this._dirs.push(dir);
    this._steps++;
  }
  // private: backtrack
  _moveBack()
  {
    this._steps--;
    this._dirs.pop();
    this._path.pop();
    this._pos = this._path[this._path.length-1];
  }
  // private: is the given direction impassable?
  _isBlocked(dir)
  {
    return !this._isPassable(this._newPosition(dir));
  }
}
module.exports = PuzzleGridWalker;
