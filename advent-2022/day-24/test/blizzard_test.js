'use strict';
const expect = require('chai').expect;
const Blizzard = require('../src/blizzard');
describe('Blizzard construction tests', () => {
  it('should construct correctly (up)', () => {
    const blizzard = new Blizzard('^', {y: -2, x: 3});
    expect(blizzard.position(), 'up position').to.eql({y: -2, x: 3});
    expect(blizzard.direction(), 'up direction').to.eql({y: 1, x: 0});
  });
  it('should construct correctly (right)', () => {
    const blizzard = new Blizzard('>', {y: -7, x: 5});
    expect(blizzard.position(), 'right position').to.eql({y: -7, x: 5});
    expect(blizzard.direction(), 'right direction').to.eql({y: 0, x: 1});
  });
  it('should construct correctly (down)', () => {
    const blizzard = new Blizzard('v', {y: -13, x: 11});
    expect(blizzard.position(), 'down position').to.eql({y: -13, x: 11});
    expect(blizzard.direction(), 'down direction').to.eql({y: -1, x: 0});
  });
  it('should construct correctly (left)', () => {
    const blizzard = new Blizzard('<', {y: -17, x: 19});
    expect(blizzard.position(), 'left position').to.eql({y: -17, x: 19});
    expect(blizzard.direction(), 'left direction').to.eql({y: 0, x: -1});
  });
  it('should throw exception on bad type character', () => {
    const badTypeFn = () => { new Blizzard('.', {y: -1, x: 1}); };
    expect(badTypeFn, "type character '.'").to.throw(SyntaxError);
  });
});
describe('Blizzard movement tests', () => {
  it('should move correctly (up)', () => {
    const blizzard = new Blizzard('^', {y: -2, x: 3});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move up from -2,3').to.eql({y: -1, x: 3});
  });
  it('should move correctly (right)', () => {
    const blizzard = new Blizzard('>', {y: -7, x: 5});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move right from -7,5').to.eql({y: -7, x: 6});
  });
  it('should move correctly (down)', () => {
    const blizzard = new Blizzard('v', {y: -13, x: 11});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move down from -13,11').to.eql({y: -14, x: 11});
  });
  it('should move correctly (left)', () => {
    const blizzard = new Blizzard('<', {y: -17, x: 19});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move left from -17,19').to.eql({y: -17, x: 18});
  });
});
// on a board with `height=20` and `width=23`
// - `y=0..-19`, blizzard travels between `-1..-18`
// - `x=0..22`, blizzard travels between `1..21`
describe('Blizzard movement tests (wrap)', () => {
  it('should move correctly (up)', () => {
    const blizzard = new Blizzard('^', {y: -1, x: 3});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move up from -1,3').to.eql({y: -18, x: 3});
  });
  it('should move correctly (right)', () => {
    const blizzard = new Blizzard('>', {y: -7, x: 21});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move right from -7,21').to.eql({y: -7, x: 1});
  });
  it('should move correctly (down)', () => {
    const blizzard = new Blizzard('v', {y: -18, x: 11});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move down from -18,11').to.eql({y: -1, x: 11});
  });
  it('should move correctly (left)', () => {
    const blizzard = new Blizzard('<', {y: -17, x: 1});
    blizzard.move({y: 20, x: 23});
    expect(blizzard.position(), 'pos after move left from -17,1').to.eql({y: -17, x: 21});
  });
});
