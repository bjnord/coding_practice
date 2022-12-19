'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const Tetris = require('../src/tetris');
const exampleInput = fs.readFileSync('input/example.txt', 'utf8');
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
    for (let i = 0; i < exampleInput.trim().length - 5; i++) {
      tetris.nextJet();
    }
    for (let i = 0; i < expected.length; i++) {
      expect(tetris.nextJet()).to.eql(expected[i]);
    }
  });
  it('should return the correct shape sequence with wrapping', () => {
    const expected = [
      {take: 1, shape: [0b1111, 0b0000, 0b0000, 0b0000]},
      {take: 3, shape: [0b1000, 0b1000, 0b1000, 0b1000]},
      {take: 1, shape: [0b1100, 0b1100, 0b0000, 0b0000]},
      {take: 3, shape: [0b1110, 0b0010, 0b0010, 0b0000]},
      {take: 4, shape: [0b0100, 0b1110, 0b0100, 0b0000]},
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
describe('Tetris play tests', () => {
  it('should have the correct heights after each shape drops', () => {
    const tetris = new Tetris(exampleInput);
    const expected = [
      1, 4, 6, 7, 9, 10, 13, 15, 17, 17,
    ];
    for (const exp of expected) {
      tetris.dropNextShape();
      expect(tetris.boardHeight()).to.equal(exp);
    }
  });
  it('should have the correct heights after many shapes drop', () => {
    const tetris = new Tetris(exampleInput);
    tetris.dropShapes(2022);
    expect(tetris.boardHeight()).to.equal(3068);
  });
});
describe('Tetris cyclical play tests', () => {
  it('should throw exception if not BigInt', () => {
    const tetris = new Tetris(exampleInput);
    const badCallFn = () => { tetris.dropShapesCyclical(1); };
    expect(badCallFn).to.throw(TypeError);
  });
  it('should compute the correct height after many, many shapes drop', () => {
    const tetris = new Tetris(exampleInput);
    const nShapes = 1000000000000n;
    const expected = 1514285714288n;
    const actual = tetris.dropShapesCyclical(nShapes);
    expect(actual).to.equal(expected);
  });
});
