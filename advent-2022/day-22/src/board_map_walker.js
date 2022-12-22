'use strict';
const math = require('../../shared/src/math');

class BoardMapWalker
{
  constructor(map, debug)
  {
    this._y = 0;
    this._x = map.rowRange(this._y)[0];
    this._dir = 90;
  }
  position()
  {
    return {y: this._y, x: this._x};
  }
  direction()
  {
    return this._dir;
  }
  turn(deg)
  {
    switch (deg) {
    case -90:
    case 90:
      this._dir = math.mod(this._dir + deg, 360);
      break;
    default:
      throw new SyntaxError(`invalid turn of '${deg}' degrees`);
      break;
    }
    return this._dir;
  }
}
module.exports = BoardMapWalker;
