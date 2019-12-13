'use strict';
const expect = require('chai').expect;
const floyd = require('../src/floyd');
describe('floyd tortoise-and-hare tests', () => {
  it('should return [17, 0] for a 5-modulo-17 sequence', () => {
    const f = (i) => ((i + 5) % 17);
    const eq = (a, b) => (a === b);
    expect(floyd.run(f, eq, 0)).to.eql([17, 0]);
  });
  it('should return [1, 11] for a divide-by-2 sequence starting at 1024', () => {
    const f = (i) => (Math.floor(i / 2));
    const eq = (a, b) => (a === b);
    expect(floyd.run(f, eq, 1024)).to.eql([1, 11]);
  });
});
