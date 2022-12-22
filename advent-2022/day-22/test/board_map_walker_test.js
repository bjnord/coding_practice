'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const gps = require('../src/gps');
const BoardMap = require('../src/board_map');
const BoardMapWalker = require('../src/board_map_walker');
const exampleLines = fs.readFileSync('input/example.txt', 'utf8');
const exampleInput = exampleLines.split('\n\n')[0];
describe('BoardMapWalker constructor tests', () => {
  it('should get the correct initial state', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    expect(walker.position(), 'walker position').to.eql({y: 0, x: 8});
    expect(walker.direction(), 'walker direction').to.eql(90);
  });
});
describe('BoardMapWalker turning tests', () => {
  it('should calculate direction/facing correctly after turns', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const tests = [
      {way: -90, newDir: 0, facingValue: 3, facingChar: '^'},
      {way: -90, newDir: 270, facingValue: 2, facingChar: '<'},
      {way: 90, newDir: 0},
      {way: -90, newDir: 270},
      {way: -90, newDir: 180, facingValue: 1, facingChar: 'v'},
      {way: -90, newDir: 90, facingValue: 0, facingChar: '>'},
      {way: -90, newDir: 0},
      {way: -90, newDir: 270},
      {way: 90, newDir: 0},
      {way: 90, newDir: 90},
      {way: 90, newDir: 180},
      {way: 90, newDir: 270},
      {way: 90, newDir: 0},
      // (180deg turns are for unit tests)
      {way: 180, newDir: 180},
      {way: 180, newDir: 0},
      {way: 90, newDir: 90},
      {way: 180, newDir: 270},
      {way: 180, newDir: 90},
    ];
    for (const test of tests) {
      const dir = walker.direction();
      expect(walker.turn(test.way), `walker turn ${test.way} from ${dir}`).to.equal(test.newDir);
      expect(walker.direction(), `walker newDir ${test.way} from ${dir}`).to.equal(test.newDir);
      if (test.facingValue !== undefined) {
        expect(walker.facingValue(), `walker facing-value ${test.way} from ${dir}`).to.equal(test.facingValue);
        expect(walker.facingChar(), `walker facing-char ${test.way} from ${dir}`).to.equal(test.facingChar);
      }
    }
  });
  it('should throw exception for invalid turn direction', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const badTurnFn = () => { walker.turn(45); };
    expect(badTurnFn).to.throw(SyntaxError);
  });
});
describe('BoardMapWalker movement tests', () => {
  it('should calculate position correctly after moves', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    const tests = [
      {turn: -90},
      {move: 1, newPos: {y: 11, x: 8}},
      {move: 5, newPos: {y: 6, x: 8}},
      {turn: 90},
      {move: 3, newPos: {y: 6, x: 11}},  // A
      {move: 1, newPos: {y: 6, x: 0}},   // B
      {turn: 90},
      {move: 1, newPos: {y: 7, x: 0}},
      {turn: -90},
      {move: 5, newPos: {y: 7, x: 5}},   // C
      {turn: 90},
      {move: 1, newPos: {y: 4, x: 5}},   // D
    ];
    for (const test of tests) {
      if (test.turn) {
        walker.turn(test.turn);
      } else {
        const pos = walker.positionString();
        expect(walker.move(test.move), `walker move ${test.move} from ${pos}`).to.eql(test.newPos);
        expect(walker.position(), `walker newPos ${test.move} from ${pos}`).to.eql(test.newPos);
      }
    }
  });
  it('should calculate position correctly after walls', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    const tests = [
      {move: 2, newPos: {y: 0, x: 10}},
      {move: 3, newPos: {y: 0, x: 10}},  // bump R 3x
      {turn: 180},
      {move: 2, newPos: {y: 0, x: 8}},
      {move: 3, newPos: {y: 0, x: 8}},   // bump L 3x (wrap)
      {turn: 180},
      {move: 2, newPos: {y: 0, x: 10}},
      {turn: 90},
      {move: 2, newPos: {y: 2, x: 10}},
      {turn: -90},
      {move: 1, newPos: {y: 2, x: 11}},
      {move: 3, newPos: {y: 2, x: 11}},  // bump R 3x (wrap)
      {turn: 90},
      {move: 1, newPos: {y: 3, x: 11}},
      {turn: -90},
      {move: 1, newPos: {y: 3, x: 8}},
      {turn: -90},
      {move: 3, newPos: {y: 3, x: 8}},   // bump U 3x
      {turn: 180},
      {move: 1, newPos: {y: 4, x: 8}},
      {turn: -90},
      {move: 2, newPos: {y: 4, x: 10}},
      {move: 1, newPos: {y: 4, x: 10}},  // bump R
      {turn: -90},
      {move: 5, newPos: {y: 11, x: 10}},
      {turn: 90},
      {move: 1, newPos: {y: 11, x: 11}},
      {turn: 90},
      {move: 2, newPos: {y: 11, x: 11}}, // bump D 2x (wrap)
    ];
    for (const test of tests) {
      if (test.turn) {
        walker.turn(test.turn);
      } else {
        const pos = walker.positionString();
        expect(walker.move(test.move), `walker move ${test.move} from ${pos}`).to.eql(test.newPos);
        expect(walker.position(), `walker newPos ${test.move} from ${pos}`).to.eql(test.newPos);
      }
    }
  });
  it('should throw exception for invalid move distance', () => {
    const map = new BoardMap('.');
    const walker = new BoardMapWalker(map);
    const badMoveFn = () => { walker.move(0); };
    expect(badMoveFn).to.throw(SyntaxError);
  });
});
describe('BoardMapWalker teleportation tests', () => {
  it('should teleport+move correctly (AB example)', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    walker._teleport(6, 11, 90);
    expect(walker.position(), 'teleport 6,11 > position').to.eql({y: 6, x: 11});
    expect(walker.facingChar(), 'teleport 6,11 > facing-char').to.equal('>');
    walker.move(1);
    expect(walker.position(), 'teleport 6,11 > post-move position').to.eql({y: 6, x: 0});
  });
  it('should teleport+move correctly (CD example)', () => {
    const map = new BoardMap(exampleInput);
    const walker = new BoardMapWalker(map);
    walker._teleport(7, 6, 180);
    expect(walker.position(), 'teleport 7,6 v position').to.eql({y: 7, x: 6});
    expect(walker.facingChar(), 'teleport 7,6 v facing-char').to.equal('v');
    walker.move(1);
    expect(walker.position(), 'teleport 7,6 v post-move position').to.eql({y: 4, x: 6});
  });
});
describe('BoardMapWalker trail tests', () => {
  it('should produce a correct trail map', () => {
    const smallInput = '        ...#    \n        .#..    \n        #...    \n        ....    \n\n3R2R3';
    const expTrail   = '        >>v#    \n        .#v.    \n        #<<.    \n        ....    \n';
    const notes = gps.parse(smallInput);
    gps.followNotes(notes);
    expect(notes.walker.trail()).to.equal(expTrail);
  });
});
