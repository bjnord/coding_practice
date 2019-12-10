'use strict';
const euclid = require('../src/euclid');

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
          this.grid.set(AsteroidMap._mapKey([y, x]), [y, x]);
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
    const g = euclid.gcd(asteroidPosition[0] - origin[0], asteroidPosition[1] - origin[1]);
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
   * Determine how many asteroids are visible from an observing origin.
   *
   * @param {Array} origin - [y, x] observing origin
   *
   * @return {number}
   *   Returns the number of asteroids visible from the given origin
   *   (excluding the origin asteroid itself).
   */
  asteroidsVisibleFrom(origin)
  {
    const asteroids = Array.from(this.grid.values()).filter((pos) => {
      return ((pos[0] !== origin[0]) || (pos[1] !== origin[1]));
    });
    return asteroids.filter((pos) => this.isVisible(origin, pos)).length;
  }
  /**
   * Determine if a location is within the asteroid map.
   *
   * @param {Array} position - [y, x] location to check
   *
   * @return {boolean}
   *   Is the given location within the bounds of the asteroid map?
   */
  inBounds(position)
  {
    return ((position[0] >= 0) && (position[0] <= this.height) &&
      (position[1] >= 0) && (position[1] <= this.width));
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
}
module.exports = AsteroidMap;
