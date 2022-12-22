'use strict';

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
}
module.exports = BoardMapWalker;
