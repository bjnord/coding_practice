'use strict';
const expect = require('chai').expect;
const Droid = require('../src/droid');
// TODO without a short example program, there's not much we can test;
//      it would be cool to work backward from the puzzle example
//      to an Intcode program that would output the correct values
//      (NOTE when implemented, remove run() "istanbul ignore next")
describe('droid constructor tests', () => {
  it('should initially have empty path', () => {
    const droid = new Droid('99');
    expect(droid.pathLength).to.eql(0);
  });
});
