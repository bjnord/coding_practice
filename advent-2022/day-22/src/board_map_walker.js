'use strict';
const math = require('../../shared/src/math');

class BoardMapWalker
{
  constructor(map, debug)
  {
    this._map = map;
    this._y = 0;
    this._x = map.rowRange(this._y)[0];
    this._dir = 90;
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
  _vertStep()
  {
    const range = this._map.columnRange(this._x);
    const rangeLen = range[1] - range[0] + 1;
    const newY = math.mod(this._y - range[0] + this._dy(), rangeLen) + range[0];
    /* istanbul ignore next */
    if (this._debug) {
      console.debug(`_vertStep range=${range[0]}-${range[1]} rangeLen=${rangeLen} y=${this._y} newY=${newY}`);
    }
    if (this._map.cellIsFloor(newY, this._x)) {
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
  _horizStep()
  {
    const range = this._map.rowRange(this._y);
    const rangeLen = range[1] - range[0] + 1;
    const newX = math.mod(this._x - range[0] + this._dx(), rangeLen) + range[0];
    /* istanbul ignore next */
    if (this._debug) {
      console.debug(`_horizStep range=${range[0]}-${range[1]} rangeLen=${rangeLen} x=${this._x} newX=${newX}`);
    }
    if (this._map.cellIsFloor(this._y, newX)) {
      this._x = newX;
    }
  }
  move(dist)
  {
    if (dist < 1) {
      throw new SyntaxError(`invalid move of ${dist} steps`);
    }
    for (let i = 0; i < dist; i++) {
      if (math.mod(this._dir, 180) === 0) {
        this._vertStep();
      } else {
        this._horizStep();
      }
    }
    return this.position();
  }
}
module.exports = BoardMapWalker;
