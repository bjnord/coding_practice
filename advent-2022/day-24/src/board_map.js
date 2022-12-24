'use strict';
const Blizzard = require('../src/blizzard');

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
      this._parseLine(line);
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
    if (this._endPos !== undefined) {
      throw new SyntaxError('middle after end');
    }
    this._parseLineContents(line);
    if ((this._height === 0) && (this._blizzards.length > 0)) {
      throw new SyntaxError('middle before start');
    }
  }
  /*
   * Parse the contents of a line of puzzle input.
   */
  _parseLineContents(line)
  {
    this._width = line.length;
    const door = BoardMap._parseEdgeLine(line);
    if (door !== undefined) {
      // start/end row
      if (this._height === 0) {
        this._startPos = {y: 0, x: door};
      } else {
        this._endPos = {y: -this._height, x: door};
      }
    } else {
      // middle row
      this._blizzards = this._blizzards.concat(BoardMap._parseLineBlizzards(line, -this._height));
    }
  }
  /*
   * Translate line characters to blizzards.
   */
  static _parseLineBlizzards(line, y)
  {
    const lineBlizzards = [];
    line.split('').forEach((ch, x) => {
      if (Blizzard.isBlizzardChar(ch)) {
        lineBlizzards.push(new Blizzard(ch, {y, x}));
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
   * Parse a start/end row, returning the `x` position of the door
   * (or `undefined`).
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
   * Get the height of the board.
   *
   * @return {number}
   *   Returns the number of rows in the board (including edges).
   */
  height()
  {
    return this._height;
  }
  /**
   * Get the width of the board.
   *
   * @return {number}
   *   Returns the number of columns in board (including edges).
   */
  width()
  {
    return this._width;
  }
  /**
   * Get the starting position.
   *
   * @return {Object}
   *   Returns the `y`,`x` starting position.
   */
  startPosition()
  {
    return this._startPos;
  }
  /**
   * Get the ending position.
   *
   * @return {Object}
   *   Returns the `y`,`x` ending position.
   */
  endPosition()
  {
    return this._endPos;
  }
  /**
   * Get the current blizzards.
   *
   * @return {Array.Blizzard}
   *   Returns a list of blizzards.
   */
  blizzards()
  {
    return this._blizzards;
  }
  /**
   * Move the blizzards.
   */
  moveBlizzards()
  {
    this._blizzards.forEach((b) => b.move({y: this._height, x: this._width}));
  }
}
module.exports = BoardMap;
