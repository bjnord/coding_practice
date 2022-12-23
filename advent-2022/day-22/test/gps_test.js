'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const gps = require('../src/gps');
const exampleInput = fs.readFileSync('input/example.txt', 'utf8');
describe('parsing tests', () => {
  it('should parse steps correctly', () => {
    const expected = [
      {move: 10},
      {turn: 90},
      {move: 5},
      {turn: -90},
      {move: 5},
      {turn: 90},
      {move: 10},
      {turn: -90},
      {move: 4},
      {turn: 90},
      {move: 5},
      {turn: -90},
      {move: 5},
    ];
    expect(gps.parseSteps('10R5L5R10L4R5L5')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const notes = gps.parse(exampleInput);
    expect(notes.steps.length).to.equal(13);
    expect(notes.map.cellIsWall(1, 9)).to.be.true;
  });
});
describe('stepping tests (flat)', () => {
  it('should calculate the final state correctly', () => {
    const notes = gps.parse(exampleInput);
    gps.followNotes(notes);
    expect(notes.walker.position(), 'final position').to.eql({y: 5, x: 7});
    expect(notes.walker.facingValue(), 'final facing-value').to.equal(0);
  });
  it('should calculate the final password correctly', () => {
    const notes = gps.parse(exampleInput);
    gps.followNotes(notes);
    expect(gps.password(notes)).to.equal(6032);
  });
});
describe('stepping tests (cube)', () => {
  it('should calculate the final state correctly', () => {
    const notes = gps.parse(exampleInput);
    gps.followNotes(notes, true);
    expect(notes.walker.position(), 'final position').to.eql({y: 4, x: 6});
    expect(notes.walker.facingValue(), 'final facing-value').to.equal(3);
  });
  it('should calculate the final password correctly', () => {
    const notes = gps.parse(exampleInput);
    gps.followNotes(notes, true);
    expect(gps.password(notes)).to.equal(5031);
  });
});
describe('trail map tests', () => {
  it('should produce a correct trail map', () => {
    const smallInput = '        ...#    \n        .#..    \n        #...    \n        ....    \n\n3R2R3';
    const expTrail   = '        >>v#    \n        .#v.    \n        #<<.    \n        ....    \n';
    const notes = gps.parse(smallInput);
    gps.followNotes(notes);
    expect(gps.renderTrail(notes)).to.equal(expTrail);
  });
});
