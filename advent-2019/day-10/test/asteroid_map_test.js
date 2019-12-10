'use strict';
const expect = require('chai').expect;
const AsteroidMap = require('../src/asteroid_map');
describe('asteroid map constructor tests', () => {
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
describe('asteroid map shade tests', () => {
});
describe('asteroid map location tests', () => {
});
