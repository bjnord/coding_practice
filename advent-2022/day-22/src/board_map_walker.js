'use strict';
const math = require('../../shared/src/math');

class BoardMapWalker
{
  constructor(map, cubic, debug)
  {
    this._map = map;
    this._trail = this._map.clone();
    this._y = 0;
    this._x = map.rowRange(this._y)[0];
    this._dir = 90;
    this._cubic = cubic;
    this._debug = debug;
  }
  position()
  {
    return {y: this._y, x: this._x};
  }
  positionString()
  {
    return `${this._y},${this._x}`;
  }
  direction()
  {
    return this._dir;
  }
  /*
   * "Facing is 0 for right (>), 1 for down (v), 2 for left (<), and
   * 3 for up (^)."
   */
  facingValue()
  {
    return math.mod(this._dir - 90, 360) / 90;
  }
  facingChar()
  {
    return ['>', 'v', '<', '^'][this.facingValue()];
  }
  turn(deg)
  {
    switch (deg) {
    case -90:
    case 90:
    case 180:
      this._dir = math.mod(this._dir + deg, 360);
      break;
    default:
      throw new SyntaxError(`invalid turn of '${deg}' degrees`);
    }
    return this._dir;
  }
  _dy()
  {
    switch (this._dir) {
    case 0:
      return -1;
    case 180:
      return 1;
    /* istanbul ignore next */
    default:
      throw new SyntaxError('_dy() for non-vertical direction');
    }
  }
  _vertOffEdge(newY)
  {
    if ((this._dy() < 0) && (newY > this._y)) {
      return true;
    } else if ((this._dy() > 0) && (newY < this._y)) {
      return true;
    } else {
      return false;
    }
  }
  _vertStep()
  {
    const range = this._map.columnRange(this._x);
    const rangeLen = range[1] - range[0] + 1;
    const newY = math.mod(this._y - range[0] + this._dy(), rangeLen) + range[0];
    /* istanbul ignore next */
    if (this._debug) {
      console.debug(`_vertStep range=${range[0]}-${range[1]} rangeLen=${rangeLen} y=${this._y} newY=${newY}`);
    }
    if (this._cubic && this._vertOffEdge(newY)) {
      const newPD = this._transformPD('y', newY);
      if (this._map.cellIsFloor(newPD.pos.y, newPD.pos.x)) {
        this._y = newPD.pos.y;
        this._x = newPD.pos.x;
        this._dir = newPD.dir;
        /* istanbul ignore next */
        if (this._debug) {
          console.debug(`completing move to ${this._y},${this._x} ${this._dir}`);
        }
      } else {
        /* istanbul ignore next */
        if (this._debug) {
          console.debug(`bumped wall; staying at ${this._y},${this._x} ${this._dir}`);
        }
      }
    } else if (this._map.cellIsFloor(newY, this._x)) {
      this._y = newY;
    }
  }
  _dx()
  {
    switch (this._dir) {
    case 270:
      return -1;
    case 90:
      return 1;
    /* istanbul ignore next */
    default:
      throw new SyntaxError('_dx() for non-horizontal direction');
    }
  }
  _horizOffEdge(newX)
  {
    if ((this._dx() < 0) && (newX > this._x)) {
      return true;
    } else if ((this._dx() > 0) && (newX < this._x)) {
      return true;
    } else {
      return false;
    }
  }
  _horizStep()
  {
    const range = this._map.rowRange(this._y);
    const rangeLen = range[1] - range[0] + 1;
    const newX = math.mod(this._x - range[0] + this._dx(), rangeLen) + range[0];
    /* istanbul ignore next */
    if (this._debug) {
      console.debug(`_horizStep range=${range[0]}-${range[1]} rangeLen=${rangeLen} x=${this._x} newX=${newX}`);
    }
    if (this._cubic && this._horizOffEdge(newX)) {
      const newPD = this._transformPD('x', newX);
      if (this._map.cellIsFloor(newPD.pos.y, newPD.pos.x)) {
        this._y = newPD.pos.y;
        this._x = newPD.pos.x;
        this._dir = newPD.dir;
        /* istanbul ignore next */
        if (this._debug) {
          console.debug(`completing move to ${this._y},${this._x} ${this._dir}`);
        }
      } else {
        /* istanbul ignore next */
        if (this._debug) {
          console.debug(`bumped wall; staying at ${this._y},${this._x} ${this._dir}`);
        }
      }
    } else if (this._map.cellIsFloor(this._y, newX)) {
      this._x = newX;
    }
  }
  _negate4(n)
  {
    const nn = (n < 0) ? (3 + n) : n;
    return nn;
  }
  _transformPos4(pos, matrix)
  {
    return {
      y: this._negate4(pos.y * matrix[0][0]) + this._negate4(pos.x * matrix[0][1]),
      x: this._negate4(pos.y * matrix[1][0]) + this._negate4(pos.x * matrix[1][1]),
    };
  }
  _transformPos(pos, matrix)
  {
    if (this._map._cells.length === 12) {
      return this._transformPos4(pos, matrix);
    } else if (this._map._cells.length === 200) {
      return this._transformPos50(pos, matrix);
    } else {
      throw new SyntaxError('_transformPos: unsupported cube size');
    }
  }
  _transformPD(axis, newCoord)
  {
    let edgeLen;
    if (this._map._cells.length === 12) {
      edgeLen = 4;
    } else if (this._map._cells.length === 200) {
      edgeLen = 50;
    } else {
      throw new SyntaxError('_transformPD: unsupported cube size');
    }
    // find face we're currently on, and edge we're walking over
    const fromPos = {y: this._y, x: this._x};
    const fromFace = this._map._face(fromPos);
    const delta = (axis === 'y') ? this._dy() : this._dx();
    const edge = this._map._edge(fromPos, axis, delta);
    // find position relative to current face
    const relPos = {y: math.mod(this._y, edgeLen), x: math.mod(this._x, edgeLen)};
    // find face we're walking onto
    const toFace = this._map._toFace(fromFace, edge);
    /* istanbul ignore next */
    if (this._debug) {
      console.debug(`relPos=${relPos.y},${relPos.x} fromFace=${fromFace} toFace=${toFace} edge=${edge}`);
    }
    // transform
    const matrix = this._map._transformMatrix(fromFace, toFace, axis, delta);
    const transPos = this._transformPos(relPos, matrix);
    /* istanbul ignore next */
    if (this._debug) {
      console.debug(`relative transPos=${transPos.y},${transPos.x} via matrix:`);
      console.dir(matrix);
    }
    const transDir = math.mod(this._dir + matrix[2], 360);
    // change relative position back to absolute
    const offset = this._map._faceOffset(toFace);
    transPos.y += offset.dy;
    transPos.x += offset.dx;
    /* istanbul ignore next */
    if (this._debug) {
      console.debug(`absolute transPos=${transPos.y},${transPos.x} transDir=${transDir}`);
    }
    // returned transformed position and direction
    return {pos: transPos, dir: transDir};
  }
  move(dist)
  {
    if (dist < 1) {
      throw new SyntaxError(`invalid move of ${dist} steps`);
    }
    for (let i = 0; i < dist; i++) {
      this._trail._setCell(this._y, this._x, this.facingChar());
      if (math.mod(this._dir, 180) === 0) {
        this._vertStep();
      } else {
        this._horizStep();
      }
    }
    return this.position();
  }
  renderTrail()
  {
    return this._trail.render();
  }
  /*
   * (This method only used by unit tests.)
   */
  _teleport(y, x, dir)
  {
    this._y = y;
    this._x = x;
    this._dir = dir;
  }
}
module.exports = BoardMapWalker;
