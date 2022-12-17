'use strict';

class Board
{
  constructor()
  {
    // element 0 is the lowest row
    this._rows = [
      0b1111111,  // floor
    ];
  }
  height()
  {
    return this._rows.length - 1;
  }
  makeSpace()
  {
    while ((this._rows.length < 4) || (this._rows[this._rows.length - 3] !== 0b0000000)) {
      this._rows.push(0b0000000);
    }
  }
  shrink()
  {
    if (this._rows[this._rows.length - 1] === 0b0000000) {
      this._rows.pop();
      return true;
    } else {
      return false;
    }
  }
  trimSpace()
  {
    while (this.shrink());
  }
  collision(mergeHeight, overlap, shape) {
    return false;  // TODO
  }
  addShape(shape, overlap)
  {
    // TODO use overlap
    for (const line of shape) {
      if (line !== 0b0000000) {
        this._rows.push(line);
      }
    }
  }
  _drawLine(line, ch)
  {
    let s = '';
    for (let i = 6; i >= 0; i--) {
      s += (line & (0b1 << i)) ? ch : '.';
    }
    console.log(`|${s}|`);
  }
  drawShape(shape, ch)
  {
    for (let i = shape.length - 1; i >= 0; i--) {
      if (shape[i] !== 0b0000000) {
        this._drawLine(shape[i], ch);
      }
    }
  }
  drawBoard()
  {
    for (let i = this._rows.length - 1; i > 0; i--) {
      this._drawLine(this._rows[i], '#');
    }
    console.log('+-------+');
    console.log('');
  }
}
module.exports = Board;
