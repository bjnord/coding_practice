'use strict';
/** @class */
class AsteroidMap
{
  /**
   * the width of the asteroid map
   * @member {number} width
   */
  /**
   * the height of the asteroid map
   * @member {number} height
   */
  /**
   * Build a new asteroid map from an input string.
   * @constructor
   *
   * @param {string} str - the input string, in puzzle format
   *   ("`.#.\n#.#\n.#.\n`"): rows of uniform length separated by
   *   newlines, with "`.`" representing empty space and "`#`"
   *   representing an asteroid
   *
   * @return {AsteroidMap}
   *   Returns a new AsteroidMap class object.
   */
  constructor(str)
  {
    const rows = str.trim().split(/\n/);
    this.grid = new Map();
    this.height = rows.length;
    for (let y = 0; y < this.height; y++) {
      this._setWidth(rows[y]);
      for (let x = 0; x < this.width; x++) {
        if (rows[y].slice(x, x+1) === '#') {
          this.grid.set([y, x], 1);
        }
      }
    }
  }
  // private: set width, and check uniformity across all rows
  _setWidth(row)
  {
    if (!this.width) {
      this.width = row.length;
    } else if (this.width !== row.length) {
      throw new Error('uneven row lengths in map');
    }
  }
  /**
   * the count of asteroids in the asteroid map
   * @member {number}
   */
  get asteroidCount()
  {
    return this.grid.size;
  }
}
module.exports = AsteroidMap;
