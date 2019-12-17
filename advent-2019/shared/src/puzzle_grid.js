'use strict';

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
   * Get the contents of a given puzzle grid position.
   *
   * @param {Array} pos - position coordinates
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
   * Get an attribute for a given puzzle grid position.
   *
   * @param {Array} pos - position coordinates
   * @param {string} attrName - attribute name
   *
   * @return {number}
   *   Returns the contents at the given position. (Will return `undefined`
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
   */
  dump()
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
          process.stdout.write(this.getAttr([y, x], 'render') || ' ');
        //}
      }
      process.stdout.write('\n');
    }
  }
}
module.exports = PuzzleGrid;
