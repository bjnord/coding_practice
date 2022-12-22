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
    this._initialize(debug);
    if (input) {
      this._parseInput(input);
    }
  }
  _initialize(debug)
  {
    this._rowRanges = [];
    this._columnRanges = [];
    this._cells = [];
    this._debug = debug;
  }
  clone()
  {
    const clone = new BoardMap(undefined, this._debug);
    clone._rowRanges = this._rowRanges.map((range) => [...range]);
    clone._columnRanges = this._columnRanges.map((range) => [...range]);
    clone._cells = this._cells.map((row) => [...row]);
    return clone;
  }
  _parseInput(input)
  {
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
  render()
  {
    return this._cells.map((row) => {
      return row.join('');
    }).join('\n').concat('\n');
  }
  /*
   * The puzzle example has 4x4 faces aligned like this:
   * ```
   * +----+
   * |  1 |
   * |234 |
   * |  56|
   * +----+
   * ```
   */
  _face4(pos)
  {
    if (pos.y < 0) {
      return undefined;
    } else if (pos.y < 4) {
      if ((8 <= pos.x) && (pos.x < 12)) {
        return 1;
      }
    } else if (pos.y < 8) {
      if ((0 <= pos.x) && (pos.x < 4)) {
        return 2;
      } else if ((4 <= pos.x) && (pos.x < 8)) {
        return 3;
      } else if ((8 <= pos.x) && (pos.x < 12)) {
        return 4;
      }
    } else if (pos.y < 12) {
      if ((8 <= pos.x) && (pos.x < 12)) {
        return 5;
      } else if ((12 <= pos.x) && (pos.x < 16)) {
        return 6;
      }
    }
    return undefined;
  }
  /*
   * My puzzle input has 50x50 faces aligned like this:
   * ```
   * +---+
   * | 12|
   * | 3 |
   * |45 |
   * |6  |
   * +---+
   * ```
   */
  _face50(pos)
  {
    if (pos.y < 0) {
      return undefined;
    } else if (pos.y < 50) {
      if ((50 <= pos.x) && (pos.x < 100)) {
        return 1;
      } else if ((100 <= pos.x) && (pos.x < 150)) {
        return 2;
      }
    } else if (pos.y < 100) {
      if ((50 <= pos.x) && (pos.x < 100)) {
        return 3;
      }
    } else if (pos.y < 150) {
      if ((0 <= pos.x) && (pos.x < 50)) {
        return 4;
      } else if ((50 <= pos.x) && (pos.x < 100)) {
        return 5;
      }
    } else if (pos.y < 200) {
      if ((0 <= pos.x) && (pos.x < 50)) {
        return 6;
      }
    }
    return undefined;
  }
  /*
   * NOTE: This is **not** a generalized cube-folding solution.
   *       It only works for the example and my puzzle input.
   */
  _face(pos)
  {
    if (this._cells.length === 12) {
      return this._face4(pos);
    } else if (this._cells.length === 200) {
      return this._face50(pos);
    } else {
      throw new SyntaxError('unsupported cube size');
    }
  }
}
module.exports = BoardMap;
