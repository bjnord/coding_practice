'use strict';
const expect = require('chai').expect;
const regolith = require('../src/regolith');
const exampleInput = '498,4 -> 498,6 -> 496,6\n503,4 -> 502,4 -> 502,9 -> 494,9';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const expected = [
      {y: 4, x: 498}, {y: 6, x: 498}, {y: 6, x: 496}
    ];
    expect(regolith.parseLine('498,4 -> 498,6 -> 496,6')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      [{y: 4, x: 498}, {y: 6, x: 498}, {y: 6, x: 496}],
      [{y: 4, x: 503}, {y: 4, x: 502}, {y: 9, x: 502}, {y: 9, x: 494}],
    ];
    expect(regolith.parse(exampleInput)).to.eql(expected);
  });
  it('should produce the map correctly', () => {
    const map = regolith.makeMap(regolith.parse(exampleInput));
    expect(Object.keys(map.grid).length).to.equal(20);
    expect(map.maxY).to.equal(9);
    expect(map.grid['5,498']).to.equal(1);
    expect(map.grid['8,502']).to.equal(1);
    expect(map.grid['4,503']).to.equal(1);
    expect(map.grid['9,494']).to.equal(1);
    expect(map.grid['0,500']).to.equal(undefined);
    expect(map.grid['4,501']).to.equal(undefined);
    expect(map.grid['6,495']).to.equal(undefined);
  });
});
describe('flow tests', () => {
  it('should simulate flow correctly', () => {
    const steps = [
      {drop: 1, rest: {y: 8, x: 500}},
      {drop: 1, rest: {y: 8, x: 499}},
      {drop: 3, rest: {y: 8, x: 498}},
      {drop: 8, rest: {y: 5, x: 500}},
      {drop: 3, rest: {y: 4, x: 500}},
      {drop: 3, rest: {y: 3, x: 500}},
      {drop: 2, rest: {y: 3, x: 501}},
      {drop: 1, rest: {y: 2, x: 500}},
      {drop: 1, rest: {y: 5, x: 497}},
      {drop: 1, rest: {y: 8, x: 495}},
    ];
    const map = regolith.makeMap(regolith.parse(exampleInput));
    for (const step of steps) {
      for (let i = 0; i < step.drop; i++) {
        //console.debug(`i=${i} expecting sand at rest`);
        //console.dir(map.grid);
        expect(regolith.dropSand(map)).to.equal(true);
      }
      const key = `${step.rest.y},${step.rest.x}`;  // FIXME DRY
      //console.debug(`expecting key=${key} to be sand`);
      expect(map.grid[key]).to.equal(2);
    }
    //console.debug('expecting fall into void');
    expect(regolith.dropSand(map)).to.equal(false);
  });
  it('should calculate total sand correctly', () => {
    const map = regolith.makeMap(regolith.parse(exampleInput));
    expect(regolith.totalSand(map)).to.equal(24);
  });
});
