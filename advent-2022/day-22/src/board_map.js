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
      this._buildEdgeFaces();
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
    clone._edgeFaces = this._edgeFaces;  // OK by reference
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
   * These are the `y`,`x` origin corners of each puzzle example face:
   */
  _faceOffset4(face)
  {
    switch(face) {
    case 1:
      return {dy: 0, dx: 8};
    case 2:
      return {dy: 4, dx: 0};
    case 3:
      return {dy: 4, dx: 4};
    case 4:
      return {dy: 4, dx: 8};
    case 5:
      return {dy: 8, dx: 8};
    case 6:
      return {dy: 8, dx: 12};
    }
    return undefined;
  }
  /*
   * These are the edge names for the puzzle example:
   * ```
   * +---------+
   * |     a   |
   * |    b1c  |
   * | a b d   |
   * |m2k3e4f  |
   * | j h g f |
   * |    h5i6c|
   * |     j m |
   * +---------+
   * ```
   */
  _edge4(pos, axis, delta)
  {
    const index = ((axis === 'y') ? 0x1 : 0x0) + ((delta < 0) ? 0x2 : 0x0);
    // these are built going clockwise starting from the right:
    let edge = undefined;
    switch (this._face4(pos)) {
    case 1:
      edge = 'cdba'.substring(index, index+1);
      break;
    case 2:
      edge = 'kjma'.substring(index, index+1);
      break;
    case 3:
      edge = 'ehkb'.substring(index, index+1);
      break;
    case 4:
      edge = 'fged'.substring(index, index+1);
      break;
    case 5:
      edge = 'ijhg'.substring(index, index+1);
      break;
    case 6:
      edge = 'cmif'.substring(index, index+1);
      break;
    }
    if (this._debug) {
      console.debug(`face=${this._face4(pos)} axis=${axis} delta=${delta} index=${index.toString(2)} edge=${edge}`);
    }
    return edge;
  }
  _transformMatrix4(fromFace, toFace, axis, delta)
  {
    const deltaChar = (delta < 0) ? '-' : '+';
    const key = `${deltaChar}${axis}${fromFace}${toFace}`;
    switch (key) {
      case '+x46':
        return [
          [ 0, -1],  // y = -x
          [-1,  0],  // x = -y
          90,        // R -> D
        ];
      case '+y52':
        return [
          [ 1,  0],  // y = y
          [ 0, -1],  // x = -x
          180,       // D -> U
        ];
      case '-y31':
        return [
          [ 0,  1],  // y = x
          [ 1,  0],  // x = y
          90,        // U -> R
        ];
      default:
        throw new SyntaxError(`_transformMatrix4:  ***  add key=${key}  ***`);
    }
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
      throw new SyntaxError('_face: unsupported cube size');
    }
  }
  _faceOffset(face)
  {
    if (this._cells.length === 12) {
      return this._faceOffset4(face);
    } else if (this._cells.length === 200) {
      return this._faceOffset50(face);
    } else {
      throw new SyntaxError('_faceOffset: unsupported cube size');
    }
  }
  _edge(pos, axis, delta)
  {
    if (this._cells.length === 12) {
      return this._edge4(pos, axis, delta);
    } else if (this._cells.length === 200) {
      return this._edge50(pos, axis, delta);
    } else {
      throw new SyntaxError('_edge: unsupported cube size');
    }
  }
  _transformMatrix(fromFace, toFace, axis, delta)
  {
    if (this._cells.length === 12) {
      return this._transformMatrix4(fromFace, toFace, axis, delta);
    } else if (this._cells.length === 200) {
      return this._transformMatrix50(fromFace, toFace, axis, delta);
    } else {
      throw new SyntaxError('_transformMatrix: unsupported cube size');
    }
  }
  _buildEdgeFaces()
  {
    this._edgeFaces = 'abcdefghijkm'.split('').reduce((h, e) => {
      h[e] = [];
      return h;
    }, {});
    if (this._cells.length === 12) {
      for (let y = 0; y < 3; y++) {
        for (let x = 0; x < 4; x++) {
          const pos = {y: y * 4, x: x * 4};
          if (this._face4(pos) === undefined) {
            continue;
          }
          for (const axis of ['x', 'y']) {
            for (const delta of [-1, 1]) {
              const edge = this._edge4(pos, axis, delta);
              if (this._debug) {
                console.debug(`pos=${pos.y},${pos.x} face=${this._face4(pos)} axis=${axis} delta=${delta} found edge=${edge}`);
              }
              this._edgeFaces[edge].push(this._face4(pos));
            }
          }
        }
      }
    } else if (this._cells.length === 200) {
      for (let y = 0; y < 4; y++) {
        for (let x = 0; x < 3; x++) {
          const pos = {y: y * 50, x: x * 50};
          if (this._face50(pos) === undefined) {
            continue;
          }
          for (const axis of ['x', 'y']) {
            for (const delta of [-1, 1]) {
              const edge = this._edge50(pos, axis, delta);
              if (this._debug) {
                console.debug(`pos=${pos.y},${pos.x} face=${this._face50(pos)} axis=${axis} delta=${delta} found edge=${edge}`);
              }
              this._edgeFaces[edge].push(this._face50(pos));
            }
          }
        }
      }
    } else if (this._cells.length <= 4) {
      // small/partial board maps used by some unit tests
    } else {
      throw new SyntaxError(`_buildEdgeFaces: unsupported cube size (rows=${this._cells.length})`);
    }
  }
  _toFace(fromFace, edge)
  {
    const pair = this._edgeFaces[edge];
    if (pair && (pair.length === 2)) {
      if (pair[0] === fromFace) {
        return pair[1];
      } else if (pair[1] === fromFace) {
        return pair[0];
      } else {
        throw new SyntaxError(`toFace(${fromFace}, ${edge}) not found in [${pair[0]}, ${pair[1]}]`);
      }
    }
    throw new SyntaxError(`toFace(${fromFace}, ${edge}) not found`);
  }
}
module.exports = BoardMap;
