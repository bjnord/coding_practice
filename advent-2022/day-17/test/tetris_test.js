'use strict';
const expect = require('chai').expect;
const Tetris = require('../src/tetris');
const exampleInput = '>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>';
describe('Tetris constructor tests', () => {
  it('should return the correct jet sequence', () => {
    const expected = [
      '>', '>', '>', '<', '<', '>', '<', '>', '>', '<',
    ];
    const tetris = new Tetris(exampleInput);
    for (let i = 0; i < expected.length; i++) {
      expect(tetris.nextJet()).to.eql(expected[i]);
    }
  });
  it('should return the correct jet sequence after wrapping', () => {
    const expected = [
      '>', '<', '<', '>', '>',
      '>', '>', '>', '<', '<',
    ];
    const tetris = new Tetris(exampleInput);
    for (let i = 0; i < exampleInput.length - 5; i++) {
      tetris.nextJet();
    }
    for (let i = 0; i < expected.length; i++) {
      expect(tetris.nextJet()).to.eql(expected[i]);
    }
  });
  it('should return the correct shape sequence with wrapping', () => {
    const expected = [
      {take: 1, shape: [0b0000, 0b0000, 0b0000, 0b1111]},
      {take: 3, shape: [0b1000, 0b1000, 0b1000, 0b1000]},
      {take: 1, shape: [0b0000, 0b0000, 0b1100, 0b1100]},
      {take: 3, shape: [0b0000, 0b0010, 0b0010, 0b1110]},
      {take: 4, shape: [0b0000, 0b0100, 0b1110, 0b0100]},
    ];
    const tetris = new Tetris(exampleInput);
    for (const exp of expected) {
      let shape;
      for (let t = 0; t < exp.take; t++) {
        shape = tetris.nextShape();
      }
      expect(shape).to.eql(exp.shape);
    }
  });
});
