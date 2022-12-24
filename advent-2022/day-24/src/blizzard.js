'use strict';

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
    this._dir = Blizzard._parseBlizzardDir(ch)
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
   * Get current position.
   *
   * @return {Object}
   *   Returns the current `y`,`x` position of this blizzard.
   */
  position()
  {
    return this._pos;
  }
  /**
   * Get direction.
   *
   * @return {Object}
   *   Returns the `dy`,`dx` direction of this blizzard.
   */
  direction()
  {
    return this._dir;
  }
}
module.exports = Blizzard;
