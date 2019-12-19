'use strict';
const expect = require('chai').expect;
const TractorBeam = require('../src/tractor_beam');

// #.........
// .#........
// ..##......
// ...###....
// ....###...
// .....####.
// ......####
// ......####
// .......###
// ........##
const puzzleExample1 = '3,20,3,21,2,21,22,24,1,24,20,24,9,24,204,25,99,0,0,0,0,0,10,10,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1';

describe('tractor beam affected-points tests [puzzle example #1]', () => {
  let example1;
  before(() => {
    example1 = new TractorBeam(puzzleExample1);
    example1.mapGrid(10, 10);
  });
  it('should compute affected points correctly', () => {
    expect(example1.pointsAffected).to.eql(27);
  });
});
