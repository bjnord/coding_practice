'use strict';

// private: map of directions to [dY, dX] offsets
const _offsets = {
  1: [-1, 0],  // up (north, -Y)
  2: [1, 0],   // down (south, +Y)
  3: [0, -1],  // left (west, -X)
  4: [0, 1],   // right (east, +X)
  5: [0, 0],   // tumbling
};

// private: maps of direction-character <-> direction
const _directions = {'^': 1, 'v': 2, '<': 3, '>': 4, 'X': 5};
const _directionChars = {1: '^', 2: 'v', 3: '<', 4: '>', 5: 'X'};

class Vacuum
{
  /**
   * Build a new vacuum.
   *
   * This class will not modify the contents of `grid`; it is only used for
   * reference during movement.
   *
   * (See `set()` for valid values for `dirChar`.)
   *
   * @param {PuzzleGrid} grid - the scaffolding grid along which the vacuum
   *   will move
   * @param {Array} [pos=[0,0]] - the initial vacuum [Y, X] position
   * @param {string} [dirChar='^'] - the character representing the initial
   *   vacuum direction
   *
   * @return {Vacuum}
   *   Returns a new Vacuum class object.
   */
  constructor(grid, pos = [0, 0], dirChar = '^')
  {
    // private: puzzle grid
    this._grid = grid;
    this.set(pos, dirChar);
  }
  /**
   * Make a copy of this vacuum.
   *
   * @return {Vacuum}
   *   Returns a copy of this Vacuum class object.
   */
  clone()
  {
    return new Vacuum(this._grid, this._pos, _directionChars[this._dir]);
  }
  /**
   * Set the current vacuum position and direction.
   *
   * Valid direction characters:
   * - `^` - up (north, -Y)
   * - `v` - down (south, +Y)
   * - `<` - left (west, -X)
   * - `>` - right (east, +X)
   * - `X` - tumbling
   *
   * @param {Array} pos - the current vacuum [Y, X] position
   * @param {string} dirChar - the character representing the current vacuum direction
   */
  set(pos, dirChar)
  {
    if (!Array.isArray(pos)) {
      throw new Error('position must be an Array');
    }
    // private: current [Y, X] position
    this._pos = pos.slice();
    if (!_directions[dirChar]) {
      throw new Error(`invalid direction character [${dirChar}]`);
    }
    // private: current direction (1=up 2=down 3=left 4=right 5=tumbling)
    this._dir = _directions[dirChar];
  }
  /**
   * the current vacuum [Y, X] position
   * @member {Array}
   */
  get position()
  {
    return this._pos;
  }
  /**
   * the character representing the current vacuum direction
   * @member {string}
   */
  get directionChar()
  {
    return _directionChars[this._dir];
  }
  /**
   * Accomplish the next action for traversing the scaffolding.
   *
   * The vacuum always proceeds straight when it can (through any "+"
   * intersections); when it reaches the end of the scaffolding and can go
   * no further, it turns right or left (assumes no "T" intersections).
   *
   * @return {string}
   *   Returns the action just taken; one of:
   *   - `'R'` - turned right
   *   - `'L'` - turned left
   *   - `'8'` - moved forward N squares
   *   - `undefined` - did not move (dead end)
   */
  step()
  {
    // the way is blocked; must turn:
    if (!this._canMoveIn(this._dir)) {
      if (this._canMoveIn(Vacuum._turnedDir(this._dir, 'R'))) {
        this._dir = Vacuum._turnedDir(this._dir, 'R');
        return 'R';
      } else if (this._canMoveIn(Vacuum._turnedDir(this._dir, 'L'))) {
        this._dir = Vacuum._turnedDir(this._dir, 'L');
        return 'L';
      } else {
        return undefined;  // dead end
      }
    };
    // follow the path forward as far as possible:
    let count = 0;
    while (this._canMoveIn(this._dir)) {
      this._pos = this._newPosition(this._dir);
      count++;
    }
    return `${count}`;
  }
  // private: calculate new vacuum position from a direction
  _newPosition(dir)
  {
    const y = this._pos[0] + _offsets[dir][0];
    const x = this._pos[1] + _offsets[dir][1];
    return [y, x];
  }
  // private: can vacuum move in the given direction?
  _canMoveIn(dir)
  {
    return this._grid.get(this._newPosition(dir)) > 0;  // scaffold or intersection
  }
  // private: transform direction+turn into new direction
  static _turnedDir(dir, turn)
  {
    switch (turn) {
    case 'R':
      return {1: 4, 2: 3, 3: 1, 4: 2, 5: 5}[dir];
    case 'L':
      return {1: 3, 2: 4, 3: 2, 4: 1, 5: 5}[dir];
    /* istanbul ignore next */
    default:
      throw new Error(`invalid turn ${turn}`);
    };
  }
  /**
   * Determine if the vacuum is an intersection.
   *
   * @return {boolean}
   *   Is the vacuum at an intersection?
   */
  atIntersection()
  {
    // is there a scaffold in every direction from this position, including
    // self?
    return Object.keys(_offsets).every((dir) => {
      return this._grid.get(this._newPosition(dir)) > 0;
    });
  }
}
module.exports = Vacuum;
