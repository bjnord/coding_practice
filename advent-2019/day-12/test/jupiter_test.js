'use strict';
const expect = require('chai').expect;
const jupiter = require('../src/jupiter');
describe('parsing tests', () => {
  it('should return [-8, -5, -6] for <x=-6, y=-5, z=-8>', () => {
    expect(jupiter.parseLine('<x=-6, y=-5, z=-8>\n')).to.eql([-8, -5, -6]);
  });
  it('should return [-13, -3, 0] for <x=0, y=-3, z=-13>', () => {
    expect(jupiter.parseLine('<x=0, y=-3, z=-13>\n')).to.eql([-13, -3, 0]);
  });
  it('should return [-11, 10, -15] for <x=-15, y=10, z=-11>', () => {
    expect(jupiter.parseLine('<x=-15, y=10, z=-11>\n')).to.eql([-11, 10, -15]);
  });
  it('should return [3, -8, -3] for <x=-3, y=-8, z=3>', () => {
    expect(jupiter.parseLine('<x=-3, y=-8, z=3>\n')).to.eql([3, -8, -3]);
  });
  it('should parse a whole input set correctly [input.txt]', () => {
    const expected = [
      {pos: [-8, -5, -6], vel: [0, 0, 0]},
      {pos: [-13, -3, 0], vel: [0, 0, 0]},
      {pos: [-11, 10, -15], vel: [0, 0, 0]},
      {pos: [3, -8, -3], vel: [0, 0, 0]},
    ];
    expect(jupiter.parse('<x=-6, y=-5, z=-8>\n<x=0, y=-3, z=-13>\n<x=-15, y=10, z=-11>\n<x=-3, y=-8, z=3>\n')).to.eql(expected);
  });
});
