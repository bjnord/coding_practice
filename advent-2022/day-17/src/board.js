'use strict';

class Board
{
  constructor(debug)
  {
    // element 0 is the lowest row
    this._rows = [
      0b1111111,  // floor
    ];
    this._debug = debug;
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
  collision(mergeRow, overlap, shape, horiz) {
    const consoleHoriz = horiz ? 'horiz ' : '';
    if (this._debug) {
      console.log(`${consoleHoriz}collision mergeRow=${mergeRow} overlap=${overlap} height=${this.height()}`);
    }
    for (let i = 0; i < overlap; i++) {
      const j = horiz ? (mergeRow + i + 1) : (mergeRow + i);
      if (j > 0) {  // above floor
        const consoleHorizJ = horiz ? 'horiz ' : '';
        if (this._debug) {
          console.log(`${consoleHorizJ}collision mergeRow=${mergeRow} i=${i}/${overlap} j=${j}`);
        }
        const boardTop = (this._rows[j] === undefined) ? 0b0000000 : this._rows[j];
        const shapeBot = shape[i];
        if (this._debug) {
          console.log('---cmp---');
          this._drawLine(shapeBot, '@');
          this._drawLine(boardTop, '#');
        }
        if ((boardTop & shapeBot) !== 0b0000000) {
          if (this._debug) {
            console.log('---!!!---');
          }
          return true;
        }
        if (this._debug) {
          console.log('---------');
        }
      } else if (this._debug) {
        console.log(`collision mergeRow=${mergeRow} i=${i}/${overlap} floor`);
      }
    }
    return false;
  }
  addShape(mergeRow, overlap, shape)
  {
    const nMerge = Math.min(overlap, shape.length);
    if (this._debug) {
      console.log(`addShape height=${this.height()} mergeRow=${mergeRow} overlap=${overlap} nMerge=${nMerge}`);
    }
    for (let r = 1; r <= nMerge; r++) {
      const line = shape.shift();
      if ((this._rows[mergeRow + r] & line) !== 0b0000000) {
        throw new SyntaxError('unexpected collision');
      }
      this._rows[mergeRow + r] |= line;
    }
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
