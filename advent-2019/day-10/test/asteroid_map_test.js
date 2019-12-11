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
describe('asteroid asteroidAt() tests', () => {
  // TODO
});
describe('asteroid map location count tests', () => {
  // TODO move constructor to before/beforeEach, split tests to their own it() calls
  // .#..#
  // .....
  // #####
  // ....#
  // ...##
  it('should see 8 asteroids from location [4, 3] [puzzle example #1]', () => {
    const asteroidMap = new AsteroidMap('.#..#\n.....\n#####\n....#\n...##\n');
    expect(asteroidMap.isVisible([4, 3], [0, 1])).to.be.false;
    expect(asteroidMap.isVisible([4, 3], [0, 4])).to.be.true;
    expect(asteroidMap.asteroidsVisibleFrom([4, 3]).length).to.eql(8);
  });
  it('should see 7 asteroids from location [0, 4] [puzzle example #1]', () => {
    const asteroidMap = new AsteroidMap('.#..#\n.....\n#####\n....#\n...##\n');
    expect(asteroidMap.asteroidsVisibleFrom([0, 4]).length).to.eql(7);
  });
  it('should see 7 asteroids from location [4, 4] [puzzle example #1]', () => {
    const asteroidMap = new AsteroidMap('.#..#\n.....\n#####\n....#\n...##\n');
    expect(asteroidMap.asteroidsVisibleFrom([4, 4]).length).to.eql(7);
  });
  it('should see 6 asteroids from location [2, 0] [puzzle example #1]', () => {
    const asteroidMap = new AsteroidMap('.#..#\n.....\n#####\n....#\n...##\n');
    expect(asteroidMap.asteroidsVisibleFrom([2, 0]).length).to.eql(6);
  });
  it('should see 5 asteroids from location [2, 4] [puzzle example #1]', () => {
    const asteroidMap = new AsteroidMap('.#..#\n.....\n#####\n....#\n...##\n');
    expect(asteroidMap.asteroidsVisibleFrom([2, 4]).length).to.eql(5);
  });
});
describe('asteroid map location tests', () => {
  // .#..#
  // .....
  // #####
  // ....#
  // ...##
  it('should find the best location [puzzle example #1]', () => {
    const asteroidMap = new AsteroidMap('.#..#\n.....\n#####\n....#\n...##\n');
    expect(asteroidMap.bestLocation()).to.eql({pos: [4, 3], count: 8});
  });
  // ......#.#.
  // #..#.#....
  // ..#######.
  // .#.#.###..
  // .#..#.....
  // ..#....#.#
  // #..#....#.
  // .##.#..###
  // ##...#..#.
  // .#....####
  it('should find the best location [puzzle example #3]', () => {
    const asteroidMap = new AsteroidMap('......#.#.\n#..#.#....\n..#######.\n.#.#.###..\n.#..#.....\n..#....#.#\n#..#....#.\n.##.#..###\n##...#..#.\n.#....####\n');
    expect(asteroidMap.bestLocation()).to.eql({pos: [8, 5], count: 33});
  });
  // #.#...#.#.
  // .###....#.
  // .#....#...
  // ##.#.#.#.#
  // ....#.#.#.
  // .##..###.#
  // ..#...##..
  // ..##....##
  // ......#...
  // .####.###.
  it('should find the best location [puzzle example #4]', () => {
    const asteroidMap = new AsteroidMap('#.#...#.#.\n.###....#.\n.#....#...\n##.#.#.#.#\n....#.#.#.\n.##..###.#\n..#...##..\n..##....##\n......#...\n.####.###.\n');
    expect(asteroidMap.bestLocation()).to.eql({pos: [2, 1], count: 35});
  });
  // .#..#..###
  // ####.###.#
  // ....###.#.
  // ..###.##.#
  // ##.##.#.#.
  // ....###..#
  // ..#.#..#.#
  // #..#.#.###
  // .##...##.#
  // .....#.#..
  it('should find the best location [puzzle example #5]', () => {
    const asteroidMap = new AsteroidMap('.#..#..###\n####.###.#\n....###.#.\n..###.##.#\n##.##.#.#.\n....###..#\n..#.#..#.#\n#..#.#.###\n.##...##.#\n.....#.#..\n');
    expect(asteroidMap.bestLocation()).to.eql({pos: [3, 6], count: 41});
  });
  // .#..##.###...#######
  // ##.############..##.
  // .#.######.########.#
  // .###.#######.####.#.
  // #####.##.#.##.###.##
  // ..#####..#.#########
  // ####################
  // #.####....###.#.#.##
  // ##.#################
  // #####.##.###..####..
  // ..######..##.#######
  // ####.##.####...##..#
  // .#####..#.######.###
  // ##...#.##########...
  // #.##########.#######
  // .####.#.###.###.#.##
  // ....##.##.###..#####
  // .#.#.###########.###
  // #.#.#.#####.####.###
  // ###.##.####.##.#..##
  it('should find the best location [puzzle example #6]', () => {
    const asteroidMap = new AsteroidMap('.#..##.###...#######\n##.############..##.\n.#.######.########.#\n.###.#######.####.#.\n#####.##.#.##.###.##\n..#####..#.#########\n####################\n#.####....###.#.#.##\n##.#################\n#####.##.###..####..\n..######..##.#######\n####.##.####...##..#\n.#####..#.######.###\n##...#.##########...\n#.##########.#######\n.####.#.###.###.#.##\n....##.##.###..#####\n.#.#.###########.###\n#.#.#.#####.####.###\n###.##.####.##.#..##\n');
    expect(asteroidMap.bestLocation()).to.eql({pos: [13, 11], count: 210});
  });
});
describe('asteroid vaporize tests', () => {
  it('should vaporize asteroids in correct order [puzzle example #7]', () => {
    const asteroidMap = new AsteroidMap('.#....#####...#..\n##...##.#####..##\n##...#...#.#####.\n..#.....#...###..\n..#.#.....#....##\n');
    const origin = [3, 8];
    const expectedFirst = [
      // .#....###24...#..
      // ##...##.13#67..9#
      // ##...#...5.8####.
      // ..#.....X...###..
      // ..#.#.....#....##
      [1, 8], [0, 9], [1, 9], [0, 10], [2, 9], [1, 11], [1, 12], [2, 11], [1, 15],
      // .#....###.....#..
      // ##...##...#.....#
      // ##...#......1234.
      // ..#.....X...5##..
      // ..#.9.....8....76
      [2, 12], [2, 13], [2, 14], [2, 15], [3, 12], [4, 16], [4, 15], [4, 10], [4, 4],
      // .8....###.....#..
      // 56...9#...#.....#
      // 34...7...........
      // ..2.....X....##..
      // ..1..............
      [4, 2], [3, 2], [2, 0], [2, 1], [1, 0], [1, 1], [2, 5], [0, 1], [1, 5],
      // ......234.....6..
      // ......1...5.....7
      // .................
      // ........X....89..
      // .................
      [1, 6], [0, 6], [0, 7],  // 4-8 still visible, 9 hidden behind 8
    ];
    expect(asteroidMap.vaporizeFrom(origin)).to.eql(expectedFirst);
    expect(asteroidMap.asteroidsVisibleFrom(origin).length).to.eql(5);
    const expectedSecond = [
      [0, 8], [1, 10], [0, 14], [1, 16], [3, 13]
    ];
    expect(asteroidMap.vaporizeFrom(origin)).to.eql(expectedSecond);
    expect(asteroidMap.asteroidsVisibleFrom(origin).length).to.eql(1);
    const expectedThird = [
      [3, 14]
    ];
    expect(asteroidMap.vaporizeFrom(origin)).to.eql(expectedThird);
    expect(asteroidMap.asteroidsVisibleFrom(origin).length).to.eql(0);
  });
  it('should vaporize asteroids in correct order [puzzle example #6]', () => {
    const asteroidMap = new AsteroidMap('.#..##.###...#######\n##.############..##.\n.#.######.########.#\n.###.#######.####.#.\n#####.##.#.##.###.##\n..#####..#.#########\n####################\n#.####....###.#.#.##\n##.#################\n#####.##.###..####..\n..######..##.#######\n####.##.####...##..#\n.#####..#.######.###\n##...#.##########...\n#.##########.#######\n.####.#.###.###.#.##\n....##.##.###..#####\n.#.#.###########.###\n#.#.#.#####.####.###\n###.##.####.##.#..##\n');
    const origin = asteroidMap.bestLocation().pos;
    let vaporized = [];
    while (asteroidMap.asteroidsVisibleFrom(origin).length) {
      vaporized = vaporized.concat(asteroidMap.vaporizeFrom(origin));
    }
    // The 1st asteroid to be vaporized is at 11,12.
    expect(vaporized[0]).to.eql([12, 11]);
    // The 2nd asteroid to be vaporized is at 12,1.
    expect(vaporized[1]).to.eql([1, 12]);
    // The 3rd asteroid to be vaporized is at 12,2.
    expect(vaporized[2]).to.eql([2, 12]);
    // The 10th asteroid to be vaporized is at 12,8.
    expect(vaporized[9]).to.eql([8, 12]);
    // The 20th asteroid to be vaporized is at 16,0.
    expect(vaporized[19]).to.eql([0, 16]);
    // The 50th asteroid to be vaporized is at 16,9.
    expect(vaporized[49]).to.eql([9, 16]);
    // The 100th asteroid to be vaporized is at 10,16.
    expect(vaporized[99]).to.eql([16, 10]);
    // The 199th asteroid to be vaporized is at 9,6.
    expect(vaporized[198]).to.eql([6, 9]);
    // The 200th asteroid to be vaporized is at 8,2.
    expect(vaporized[199]).to.eql([2, 8]);
    // The 201st asteroid to be vaporized is at 10,9.
    expect(vaporized[200]).to.eql([9, 10]);
    // The 299th and final asteroid to be vaporized is at 11,1.
    expect(vaporized[298]).to.eql([1, 11]);
    expect(vaporized.length).to.eql(299);
  });
});
