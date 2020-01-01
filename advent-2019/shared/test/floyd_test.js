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
  it('should return [1, 0] for a modulo-5-div-3 comparison sequence', () => {
    // here we are using eq() to test a _derivative_ of the f() values
    // f() goes (0, 1, 2, 3, ...) but eq() tests (0, 0, 0, 1, 1, 1, ...)
    // NB Floyd's alg. doesn't detect the 15-element cycle in this case!
    const f = (i) => (i + 1);
    const eq = (a, b) => (Math.floor((a%5)/3) === Math.floor((b%5)/3));
    expect(floyd.run(f, eq, 0)).to.eql([1, 0]);
  });
  it("should return [1, 101] for a 100-item sequence that doesn't repeat", () => {
    const seq = [...Array(100).keys()].map((x) => x+1);
    const f = (i) => seq[i];
    const eq = (a, b) => (a === b);
    expect(floyd.run(f, eq, 0)).to.eql([1, 101]);
  });
});
