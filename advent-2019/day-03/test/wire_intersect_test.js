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
  it("should find 2 wires' closest intersection correctly [case 1]", () => {
    let wire = new Wire('R8,U5,L5,D3');
    let wire2 = new Wire('U7,R6,D4,L4');
    expect(wire.closestIntersectionWith(wire2)).to.eql(6);
  });
  it("should find 2 wires' closest intersection correctly [case 2]", () => {
    let wire = new Wire('R75,D30,R83,U83,L12,D49,R71,U7,L72');
    let wire2 = new Wire('U62,R66,U55,R34,D71,R55,D58,R83');
    expect(wire.closestIntersectionWith(wire2)).to.eql(159);
  });
  it("should find 2 wires' closest intersection correctly [case 3]", () => {
    let wire = new Wire('R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51');
    let wire2 = new Wire('U98,R91,D20,R16,D67,R40,U7,R15,U6,R7');
    expect(wire.closestIntersectionWith(wire2)).to.eql(135);
  });
});
