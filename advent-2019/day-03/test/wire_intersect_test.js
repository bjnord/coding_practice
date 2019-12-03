var expect = require('chai').expect;
var Wire = require('../src/wire');
describe('wire intersect tests', () => {
  it("should find 2 wires' intersections correctly", () => {
    let wire = new Wire('R8,U5,L5,D3');
    let wire2 = new Wire('U7,R6,D4,L4');
    let intersections = wire.intersectionsWith(wire2);
    expect(intersections).to.be.an('array');
    expect(intersections).to.be.lengthOf(2);
    expect(intersections).to.not.deep.include([0, 0]);
    expect(intersections).to.deep.include([-3, 3]);
    expect(intersections).to.deep.include([-5, 6]);
  });
});
