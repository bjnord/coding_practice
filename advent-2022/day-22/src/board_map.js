'use strict';

const BOARD_MAP_FLOOR = '.';
const BOARD_MAP_WALL = '#';
const BOARD_MAP_VOID = ' ';

/*
 * NOTE that the `y` axis is positive in the downward direction
 */
class BoardMap
{
  constructor(input, debug)
  {
    this._rowRanges = [];
    this._columnRanges = [];
    this._cells = [];
    input.split('\n').forEach((line, y) => {
      // important not to `trim()` here (need leading spaces)
      line.split('').forEach((ch, x) => {
        if ((ch === BOARD_MAP_FLOOR) || (ch === BOARD_MAP_WALL)) {
          this._extendColumnRange(y, x);
          this._extendRowRange(y, x);
        } else if (ch !== BOARD_MAP_VOID) {
          throw new SyntaxError(`unknown board character '${ch}'`);
        }
        this._setCell(y, x, ch);
      });
    });
    this._debug = debug;
  }
  _extendColumnRange(y, x)
  {
    if (!this._columnRanges[x]) {
      this._columnRanges[x] = [y, y];
    } else if (this._columnRanges[x][1] !== (y - 1)) {
      throw new SyntaxError(`_extendColumnRange(${y},${x}) discontinuous`);
    } else {
      this._columnRanges[x][1] = y;
    }
  }
  _extendRowRange(y, x)
  {
    if (!this._rowRanges[y]) {
      this._rowRanges[y] = [x, x];
    } else if (this._rowRanges[y][1] !== (x - 1)) {
      throw new SyntaxError(`_extendRowRange(${y},${x}) discontinuous`);
    } else {
      this._rowRanges[y][1] = x;
    }
  }
  _setCell(y, x, ch)
  {
    if (!this._cells[y]) {
      this._cells[y] = [];
    }
    this._cells[y][x] = ch;
  }
  columnRange(x)
  {
    if (!this._columnRanges[x]) {
      throw new SyntaxError(`no columnRange[${x}]`);
    }
    return this._columnRanges[x];
  }
  rowRange(y)
  {
    if (!this._rowRanges[y]) {
      throw new SyntaxError(`no rowRange[${y}]`);
    }
    return this._rowRanges[y];
  }
  _cellEquals(y, x, ch)
  {
    if (this._cells[y] && this._cells[y][x]) {
      return this._cells[y][x] === ch;
    } else {
      return undefined;
    }
  }
  cellIsFloor(y, x)
  {
    return this._cellEquals(y, x, BOARD_MAP_FLOOR);
  }
  cellIsWall(y, x)
  {
    return this._cellEquals(y, x, BOARD_MAP_WALL);
  }
  cellIsVoid(y, x)
  {
    const eq = this._cellEquals(y, x, BOARD_MAP_VOID);
    return (eq === true) || (eq === undefined);
  }
}
module.exports = BoardMap;
