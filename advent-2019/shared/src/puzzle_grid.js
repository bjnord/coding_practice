'use strict';

// private: map of directions to [dY, dX] offsets
const _offsets = {
  1: [-1, 0],  // up (north, -Y)
  2: [1, 0],   // down (south, +Y)
  3: [0, -1],  // left (west, -X)
  4: [0, 1],   // right (east, +X)
};

class PuzzleGrid
{
  /**
   * Create a new puzzle grid.
   *
   * The key for the grid is an object that looks like this:
   *
   * ```
   * {
   *   0: {name: 'wall', render: '#'},
   *   1: {name: 'open', render: '.'},
   *   // ...
   * }
   * ```
   *
   * Coordinates for the positions on the grid are given as an `Array` of
   * integers in the form `[Y, X]`. The grid is an "infinite plane," so any
   * coordinates are treated as valid (positive or negative); setting
   * contents at a more distant position effectively expands the grid size.
   *
   * @param {object} key - the grid key
   *
   * @return {PuzzleGrid}
   *   Returns a new PuzzleGrid class object.
   */
  constructor(key)
  {
    // private: the grid
    this._grid = new Map();
    // private: the grid key
    this._key = key;
  }
  /**
   * Factory: Create a new puzzle grid by parsing a list of input strings.
   *
   * The input lines need not be of uniform length (a puzzle grid is a
   * "sparse" map; any coordinates may have `undefined` contents). All
   * characters in an input line are treated as significant, so lines
   * should not have spaces, newlines, etc. (unless they are to be parsed
   * and stored in the grid).
   *
   * If an `originOffset` is provided, those `[oY, oX]` values will be
   * _subtracted_ from all coordinates. For example, with offset `[2, 2]`
   * a 4x6 grid will run from `[-2, -2]` (upper-left corner) to `[1, 3]`
   * (lower-right corner).
   *
   * The `unknownType` callback is useful for moveable objects. If provided,
   * it will be called for any input line character that is not found in the
   * `key` (as a `render` value), with these arguments:
   * - `pos` - [Y, X] position in grid (including any `originOffset`)
   * - `ch` - the character of unknown type
   *
   * The callback should return the contents that should be stored for this
   * position (e.g. the grid type "underneath" a moveable object), or
   * `undefined` to not store anything. If a value is returned, it should
   * normally be one of the keys in `key`.
   *
   * If the `unknownType` callback is not provided, the parser will store
   * `null` as the grid position contents for any unknown character type.
   *
   * @param {Array} lines - the list of input strings
   * @param {object} key - the grid key (see constructor for format)
   * @param {Array} [originOffset=[0, 0]] - the origin offset
   * @param {function} [unknownType] - unknown-type callback
   *
   * @return {PuzzleGrid}
   *   Returns a new PuzzleGrid class object.
   */
  static from(lines, key, originOffset = [0, 0], callback = undefined)
  {
    const puzzleGrid = new PuzzleGrid(key);
    // "I have a dream."
    const contentOfCharacter = new Map(Object.entries(key).map(([k, v]) => [v.render, Number(k)]));
    let y = originOffset[0], x = originOffset[1];
    while (lines.length > 0) {
      // ignore empty lines at end, if any:
      if (!lines[0] && lines.every((l) => !l)) {
        break;
      }
      // TODO RF move guts to private "decode character" helper function WITH TESTS
      //      should return `undefined` (don't store), or contents to store
      lines.shift().split('').forEach((v) => {
        let contents = contentOfCharacter.get(v);
        //console.debug(`v=[${v}] contents @ [${y}, ${x}] = ${contents} type ${typeof contents}`);
        if (contents !== undefined) {
          puzzleGrid.set([y, x], contents);
        } else if (callback) {
          if ((contents = callback([y, x], v)) !== undefined) {
            puzzleGrid.set([y, x], contents);
          }
        } else {
          puzzleGrid.set([y, x], null);  // unknown type
        }
        x++;
      });
      y++;
      x = originOffset[1];
    }
    return puzzleGrid;
  }
  /**
   * Get the contents of a given puzzle grid position.
   *
   * @param {Array} pos - [Y, X] position coordinates
   *
   * @return {number}
   *   Returns the contents at the given position. (Will return `undefined`
   *   if contents have not yet been set there.)
   */
  get(pos)
  {
    return this._grid.get(PuzzleGrid._gridKey(pos));
  }
  /**
   * Get the contents adjacent to a given puzzle grid position in the
   * provided direction.
   *
   * Directions are:
   * - `1` - up (north, -Y)
   * - `2` - down (south, +Y)
   * - `3` - left (west, -X)
   * - `4` - right (east, +X)
   *
   * @param {Array} pos - [Y, X] position coordinates
   * @param {Array} dir - direction
   *
   * @return {number}
   *   Returns the contents at the adjacent position. (Will return
   *   `undefined` if contents have not yet been set there.)
   */
  getInDirection(pos, dir)
  {
    return this._grid.get(PuzzleGrid._gridKey(PuzzleGrid._newPosition(pos, dir)));
  }
  // private: calculate new position from direction
  static _newPosition(pos, dir)
  {
    const y = pos[0] + _offsets[dir][0];
    const x = pos[1] + _offsets[dir][1];
    return [y, x];
  }
  /**
   * Get an attribute for a given puzzle grid position.
   *
   * @param {Array} pos - position coordinates
   * @param {string} attrName - attribute name
   *
   * @return {number}
   *   Returns the attribute at the given position. (Will return `undefined`
   *   if contents have not yet been set there.)
   */
  getAttr(pos, attrName)
  {
    const v = this._grid.get(PuzzleGrid._gridKey(pos));
    return this._key[v] ? this._key[v][attrName] : undefined;
  }
  /**
   * Set the contents of a given puzzle grid position.
   *
   * @param {Array} pos - position coordinates
   * @param {number} value - the contents - must be one of the values
   *   defined in the puzzle grid key (see constructor)
   */
  set(pos, value)
  {
    this._grid.set(PuzzleGrid._gridKey(pos), value);
  }
  // private: grid key for a given [Y, X] position
  static _gridKey(position)
  {
    return `${position[0]},${position[1]}`;
  }
  /* istanbul ignore next */
  /**
   * Display the grid.
   *
   * @param {string} [unknownChar=' '] - character to display for unknown content type
   */
  dump(unknownChar = ' ')
  {
    const squares = Array.from(this._grid.keys()).map((k) => k.split(/,/).map((str) => Number(str)));
    const squareMin = squares.reduce((mins, p) => [Math.min(p[0], mins[0]), Math.min(p[1], mins[1])], [999999, 999999]);
    const squareMax = squares.reduce((maxes, p) => [Math.max(p[0], maxes[0]), Math.max(p[1], maxes[1])], [-999999, -999999]);
    for (let y = squareMin[0]; y <= squareMax[0]; y++) {
      for (let x = squareMin[1]; x <= squareMax[1]; x++) {
        // TODO allow setting grid "options" for things like this
        //if ((y === 0) && (x === 0)) {
        //  process.stdout.write(':');  // origin
        //} else {
          process.stdout.write(this.getAttr([y, x], 'render') || unknownChar);
        //}
      }
      process.stdout.write('\n');
    }
  }
}
module.exports = PuzzleGrid;
