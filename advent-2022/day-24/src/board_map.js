'use strict';

class BoardMap
{
  /**
   * Construct a board from the puzzle input.
   *
   * @param {string} input - lines of puzzle input separated by `\n`
   * @param {boolean} debug - (optional) enable debugging
   */
  constructor(input, debug)
  {
    this._blizzards = [];
    this._parse(input);
    this._debug = debug;
  }
  /*
   * Parse the puzzle input.
   */
  _parse(input)
  {
    this._height = 0;
    for (const line of input.trim().split(/\n/)) {
      if (this._endPos !== undefined) {
        throw new SyntaxError('floor after end');
      }
      this._parseLine(line);
      if ((this._height === 0) && (this._blizzards.length > 0)) {
        throw new SyntaxError('floor before start');
      }
      this._height += 1;
    }
    if (this._endPos === undefined) {
      throw new SyntaxError('end not found');
    }
  }
  /*
   * Parse a line of puzzle input.
   */
  _parseLine(line)
  {
    this._width = line.length;
    const door = BoardMap._parseEdgeLine(line);
    if (door !== undefined) {
      if (this._height === 0) {
        this._startPos = {y: 0, x: door};
      } else {
        this._endPos = {y: -this._height, x: door};
      }
    } else {
      this._blizzards = this._blizzards.concat(BoardMap._parseLineBlizzards(line, this._height));
    }
  }
  /*
   * Translate line character to blizzard direction.
   */
  static _parseBlizzardDir(ch)
  {
    const chars = '^>v<';
    const dirs = [
      {y: 1, x: 0},
      {y: 0, x: 1},
      {y: -1, x: 0},
      {y: 0, x: -1},
    ];
    return dirs[chars.indexOf(ch)];
  }
  /*
   * Translate line characters to blizzards.
   */
  static _parseLineBlizzards(line, y)
  {
    const lineBlizzards = [];
    line.split('').forEach((ch, x) => {
      const dir = BoardMap._parseBlizzardDir(ch);
      if (dir) {
        lineBlizzards.push({pos: {y, x}, dir});
      } else if ((ch !== '#') && (ch !== '.')) {
        throw new SyntaxError(`unknown cell '${ch}' at ${y},${x}`);
      }
    });
    return lineBlizzards;
  }
  /*
   * Is this a start/end row?
   */
  static _parseIsStartEnd(line)
  {
    return (line.substring(0, 2) === '##')
      || (line.substring(line.length - 2) === '##');
  }
  /*
   * Parse start/end row, returning X position of door (or `undefined`).
   */
  static _parseEdgeLine(line)
  {
    if (BoardMap._parseIsStartEnd(line)) {
      const door = line.indexOf('.');
      if (door < 0) {
        throw new SyntaxError('top/bottom line with no door');
      }
      return door;
    } else {
      return undefined;
    }
  }
  /**
   * Get height of board.
   *
   * @return {number}
   *   Returns the number of rows in board (including edges).
   */
  height()
  {
    return this._height;
  }
  /**
   * Get width of board.
   *
   * @return {number}
   *   Returns the number of columns in board (including edges).
   */
  width()
  {
    return this._width;
  }
  /**
   * Get starting position.
   *
   * @return {Object}
   *   Returns the `y`,`x` starting position.
   */
  startPosition()
  {
    return this._startPos;
  }
  /**
   * Get ending position.
   *
   * @return {Object}
   *   Returns the `y`,`x` ending position.
   */
  endPosition()
  {
    return this._endPos;
  }
  /**
   * Get current blizzards.
   *
   * @return {Array.Object}
   *   Returns a list of blizzard `y`,`x` positions and directions.
   */
  blizzards()
  {
    return this._blizzards;
  }
}
module.exports = BoardMap;
