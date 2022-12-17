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
    //console.log('');
    //console.log('spacious:');
    //board.drawBoard();
    expect(board.height()).to.equal(3);
    board.makeSpace();
    expect(board.height()).to.equal(3);
    board.shrink();
    //console.log('');
    //console.log('short people got:');
    //board.drawBoard();
    expect(board.height()).to.equal(2);
    board.trimSpace();
    //console.log('');
    //console.log('neatly trimmed:');
    //board.drawBoard();
    expect(board.height()).to.equal(0);
    board.trimSpace();
    expect(board.height()).to.equal(0);
    board.shrink();
    expect(board.height()).to.equal(0);
  });
});
