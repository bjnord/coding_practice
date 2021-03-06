'use strict';
const util = require('../../shared/src/util');

class AsteroidMap
{
  /**
   * Build a new asteroid map from an input string.
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
    /**
     * the height of the asteroid map
     * @member {number}
     */
    this.height = rows.length;
    for (let y = 0; y < this.height; y++) {
      this._setWidth(rows[y]);
      for (let x = 0; x < this.width; x++) {
        if (rows[y].slice(x, x+1) === '#') {
          this.grid.set(AsteroidMap._mapKey([y, x]), [y, x]);
        }
      }
    }
  }
  // private: set width, and check uniformity across all rows
  _setWidth(row)
  {
    if (!this.width) {
      /**
       * the width of the asteroid map
       * @member {number}
       */
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
  /**
   * Determine if an asteroid is visible from an observing origin.
   *
   * @param {Array} origin - [y, x] observing origin
   * @param {Array} asteroidPosition - [y, x] location of asteroid
   *
   * @return {boolean}
   *   Is the given asteroid visible from the given observing origin?
   */
  isVisible(origin, asteroidPosition)
  {
    const g = util.euclidGCD(asteroidPosition[0] - origin[0], asteroidPosition[1] - origin[1]);
    const dy = (asteroidPosition[0] - origin[0]) / g;
    const dx = (asteroidPosition[1] - origin[1]) / g;
    for (let y = origin[0] + dy, x = origin[1] + dx; (y !== asteroidPosition[0]) || (x !== asteroidPosition[1]); y += dy, x += dx) {
      if (this.asteroidAt([y, x])) {
        return false;
      }
    }
    return true;
  }
  /**
   * Find asteroids that are visible from an observing origin.
   *
   * @param {Array} origin - [y, x] observing origin
   *
   * @return {Array}
   *   Returns a list of the [y, x] positions of asteroids visible from the
   *   given origin (excluding the origin asteroid itself).
   */
  asteroidsVisibleFrom(origin)
  {
    const asteroids = Array.from(this.grid.values()).filter((pos) => {
      return ((pos[0] !== origin[0]) || (pos[1] !== origin[1]));
    });
    return asteroids.filter((pos) => this.isVisible(origin, pos));
  }
  /**
   * Determine observing location which can see the most asteroids.
   *
   * Has performance O(n^3): O(n^2) with the number of asteroids in the map,
   * times O(n) with the size of the map.
   *
   * @return {object}
   *   Returns the observing location which can see the most (other)
   *   asteroids, with the following fields:
   *   - `pos` - [y, x] coordinates of location
   *   - `count` - number of asteroids visible from location
   */
  bestLocation()
  {
    return Array.from(this.grid.values()).reduce((acc, pos) => {
      const count = this.asteroidsVisibleFrom(pos).length;
      return (count > acc.count) ? {pos, count} : acc;
    }, {pos: null, count: 0});
  }
  /**
   * Vaporize asteroids visible from an observing origin. This **removes**
   * the vaporized asteroids from the `AsteroidMap`.
   *
   * @param {Array} origin - [y, x] observing origin
   *
   * @return {Array}
   *   Returns a list of [y, x] positions of the asteroids vaporized, in
   *   order of clockwise laser beam sweep.
   */
  vaporizeFrom(origin)
  {
    const positions = this.asteroidsVisibleFrom(origin).sort((a, b) => AsteroidMap._polarAngle(origin, a) - AsteroidMap._polarAngle(origin, b));
    positions.forEach((pos) => this.grid.delete(AsteroidMap._mapKey(pos)));
    return positions;
  }
  /**
   * Determine if there is an asteroid at a location in the asteroid map.
   *
   * @param {Array} position - [y, x] location to check
   *
   * @return {boolean}
   *   Does the given location in the asteroid map have an asteroid?
   */
  asteroidAt(position)
  {
    return this.grid.get(AsteroidMap._mapKey(position)) ? true : false;
  }
  // private: map key for a given [y, x] location
  static _mapKey(position)
  {
    return `${position[0]},${position[1]}`;
  }
  // private: polar angle (radians) from origin to position
  //          clockwise  [0, 2pi)  where 0 = along -Y axis
  static _polarAngle(origin, position)
  {
    const dy = position[0] - origin[0];
    const dx = position[1] - origin[1];
    if (dy >= 0) {
      return Math.PI + Math.atan(dx / -dy);
    } else if ((dy < 0) && (dx < 0)) {
      return Math.PI*2.0 + Math.atan(dx / -dy);
    } else {
      return Math.atan(dx / -dy);
    }
  }
}
module.exports = AsteroidMap;
