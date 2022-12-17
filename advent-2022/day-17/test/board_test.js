'use strict';
const expect = require('chai').expect;
const Board = require('../src/board');
describe('Board constructor tests', () => {
  let board;
  before(() => {
    board = new Board();
  });
  it('should return the correct initial height', () => {
    expect(board.height()).to.equal(0);
  });
});
describe('Board operation tests', () => {
  it('should make and trim space (initial board)', () => {
    const board = new Board();
    board.makeSpace();
//  console.log('');
//  console.log('spacious:');
//  board.drawBoard();
    expect(board.height()).to.equal(3);
    board.makeSpace();
    expect(board.height()).to.equal(3);
    board.shrink();
//  console.log('');
//  console.log('short people got:');
//  board.drawBoard();
    expect(board.height()).to.equal(2);
    board.trimSpace();
//  console.log('');
//  console.log('neatly trimmed:');
//  board.drawBoard();
    expect(board.height()).to.equal(0);
    board.trimSpace();
    expect(board.height()).to.equal(0);
    board.shrink();
    expect(board.height()).to.equal(0);
  });
});
describe('Board operation tests', () => {
  it('should calculate board state correctly', () => {
    const board = new Board();
    expect(board.state()).to.equal(undefined);
    const shapes = [
      [0b0010000, 0b0011000, 0b0011100, 0b0011110],
      [0b0000010, 0b0000110, 0b0001110, 0b0011110],
    ];
    // drop enough 4-height shapes to fill stateHeight 3x:
    const nShapes = Board.stateRows / shapes[0].length * 3;
    for (let i = 0, lastSum = undefined; i < nShapes; i++) {
      board.addShape(i * 4, 0, shapes[i % 2]);
      expect(board.nShapesAdded()).to.equal(i + 1);
      expect(board.height()).to.equal((i + 1) * 4);
      expect(board.state().afterShape).to.equal(i % 5);
      expect(board.state().sum).to.not.equal(lastSum);
//    console.debug(`nShapes=${nShapes} i=${i} lastSum=${lastSum} sum=${board.state().sum}`);
      lastSum = board.state().sum;
    }
  });
});
