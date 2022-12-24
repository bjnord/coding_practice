'use strict';
const math = require('../../shared/src/math');

const _BLIZZARD_CHARS = '^>v<';

class Blizzard
{
  /**
   * Construct a new blizzard.
   *
   * @param {string} ch - the blizzard type character (`^`, `>`, `v`, or `<`)
   * @param {Object} pos - the initial `y`,`x` position
   */
  constructor(ch, pos)
  {
    if (!Blizzard.isBlizzardChar(ch)) {
      throw new SyntaxError(`invalid type character '${ch}'`);
    }
    this._pos = pos;
    this._dir = Blizzard._parseBlizzardDir(ch);
  }
  /*
   * Translate line character to blizzard direction.
   */
  static _parseBlizzardDir(ch)
  {
    const dirs = [
      {y: 1, x: 0},
      {y: 0, x: 1},
      {y: -1, x: 0},
      {y: 0, x: -1},
    ];
    return dirs[_BLIZZARD_CHARS.indexOf(ch)];
  }
  /**
   * Is this a valid blizzard type character?
   *
   * @return {boolean}
   *   Returns `true` if the given character is a blizzard type; otherwise
   *   `false`.
   */
  static isBlizzardChar(ch)
  {
    return _BLIZZARD_CHARS.indexOf(ch) >= 0;
  }
  /**
   * Get the current position.
   *
   * @return {Object}
   *   Returns the current `y`,`x` position of this blizzard.
   */
  position()
  {
    return this._pos;
  }
  /**
   * Get the direction.
   *
   * @return {Object}
   *   Returns the `dy`,`dx` direction of this blizzard.
   */
  direction()
  {
    return this._dir;
  }
  /**
   * Move the blizzard, given a map of `dim` dimensions.
   *
   * @param {Object} dim - `y`,`x` dimensions of map (including edges)
   */
  move(dim)
  {
    this._pos.y = -(math.mod((-this._pos.y - 1) + -this._dir.y, dim.y - 2) + 1);
    this._pos.x =  (math.mod(( this._pos.x - 1) +  this._dir.x, dim.x - 2) + 1);
  }
}
module.exports = Blizzard;
