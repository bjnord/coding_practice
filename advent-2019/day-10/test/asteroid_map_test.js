'use strict';
const expect = require('chai').expect;
const AsteroidMap = require('../src/asteroid_map');
describe('asteroid map constructor tests', () => {
  // .#..#
  // .....
  // #####
  // ....#
  // ...##
  it('should parse 5x5 asteroid map correctly [puzzle example #1]', () => {
    const asteroidMap = new AsteroidMap('.#..#\n.....\n#####\n....#\n...##\n');
    expect(asteroidMap.asteroidCount).to.eql(10);
    expect(asteroidMap.width).to.eql(5);
    expect(asteroidMap.height).to.eql(5);
  });
  it('should parse 7x6 asteroid map correctly [non-square]', () => {
    const asteroidMap = new AsteroidMap('.#.##.#\n...##..\n##..###\n.#.#..#\n.......\n#...###\n');
    expect(asteroidMap.asteroidCount).to.eql(18);
    expect(asteroidMap.width).to.eql(7);
    expect(asteroidMap.height).to.eql(6);
  });
  it('should throw an exception for uneven row lengths', () => {
    const call = () => { new AsteroidMap('.#.\n#.#\n.#..\n'); };
    expect(call).to.throw(Error, 'uneven row lengths in map');
  });
});
describe('asteroid map visibility tests', () => {
  // TODO move constructor to before/beforeEach, split tests to their own it() calls
  // #.........
  // ...A......
  // ...B..a...
  // .EDCG....a
  // ..F.c.b...
  // .....c....
  // ..efd.c.gb
  // .......c..
  // ....f...c.
  // ...e..d..c
  it('should detect asteroid hiddenness correctly [puzzle example #2]', () => {
    const asteroidMap = new AsteroidMap('#.........\n...#......\n...#..#...\n.####....#\n..#.#.#...\n.....#....\n..###.#.##\n.......#..\n....#...#.\n...#..#..#\n');
    expect(asteroidMap.asteroidCount).to.eql(25);
    expect(asteroidMap.width).to.eql(10);
    expect(asteroidMap.height).to.eql(10);
    [[2, 6], [3, 9]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.false);  // Aa
    [[3, 6]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.true);  // A.
    [[4, 6], [6, 9]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.false);  // Bb
    [[4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.false);  // Cc
    [[6, 4], [9, 6]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.false);  // Dd
    [[4, 3], [7, 8]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.true);  // C&D.
    [[6, 2], [9, 3]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.false);  // Ee
    [[6, 3], [8, 4]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.false);  // Ff
    [[6, 8]].forEach((pos) => expect(asteroidMap.isVisible([0, 0], pos)).to.be.false);  // Gg
  });
  // TODO should throw exception if origin==asteroidPosition
  it('should not include the observing origin or target asteroid', () => {
    const asteroidMap = new AsteroidMap('#..\n...\n..#\n');
    expect(asteroidMap.asteroidCount).to.eql(2);
    expect(asteroidMap.width).to.eql(3);
    expect(asteroidMap.height).to.eql(3);
    expect(asteroidMap.isVisible([0, 0], [2, 2])).to.be.true;
  });
  it('should be visible from either direction', () => {
    const asteroidMap = new AsteroidMap('#..\n...\n..#\n');
    expect(asteroidMap.asteroidCount).to.eql(2);
    expect(asteroidMap.width).to.eql(3);
    expect(asteroidMap.height).to.eql(3);
    expect(asteroidMap.isVisible([0, 0], [2, 2])).to.be.true;
    expect(asteroidMap.isVisible([2, 2], [0, 0])).to.be.true;
  });
  it('should be blocked from either direction', () => {
    const asteroidMap = new AsteroidMap('#..\n.#.\n..#\n');
    expect(asteroidMap.asteroidCount).to.eql(3);
    expect(asteroidMap.width).to.eql(3);
    expect(asteroidMap.height).to.eql(3);
    expect(asteroidMap.isVisible([0, 0], [2, 2])).to.be.false;
    expect(asteroidMap.isVisible([2, 2], [0, 0])).to.be.false;
  });
});
describe('asteroid inBounds() tests', () => {
  // TODO
});
describe('asteroid asteroidAt() tests', () => {
  // TODO
});
describe('asteroid map location tests', () => {
});
