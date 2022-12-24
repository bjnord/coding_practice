'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const Blizzard = require('../src/blizzard');
describe('Blizzard construction tests', () => {
  it('should construct correctly (up)', () => {
    const blizzard = new Blizzard('^', {y: 2, x: 3});
    expect(blizzard.position(), 'up position').to.eql({y: 2, x: 3});
    expect(blizzard.direction(), 'up direction').to.eql({y: 1, x: 0});
  });
  it('should construct correctly (right)', () => {
    const blizzard = new Blizzard('>', {y: 7, x: 5});
    expect(blizzard.position(), 'right position').to.eql({y: 7, x: 5});
    expect(blizzard.direction(), 'right direction').to.eql({y: 0, x: 1});
  });
  it('should construct correctly (down)', () => {
    const blizzard = new Blizzard('v', {y: 13, x: 11});
    expect(blizzard.position(), 'down position').to.eql({y: 13, x: 11});
    expect(blizzard.direction(), 'down direction').to.eql({y: -1, x: 0});
  });
  it('should construct correctly (left)', () => {
    const blizzard = new Blizzard('<', {y: 17, x: 19});
    expect(blizzard.position(), 'left position').to.eql({y: 17, x: 19});
    expect(blizzard.direction(), 'left direction').to.eql({y: 0, x: -1});
  });
  it('should throw exception on bad type character', () => {
    const badTypeFn = () => { new Blizzard('.', {y: 1, x: 1}); };
    expect(badTypeFn, "type character '.'").to.throw(SyntaxError);
  });
});
