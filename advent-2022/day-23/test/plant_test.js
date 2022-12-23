'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const plant = require('../src/plant');
const smallExInput = '.....\n..##.\n..#..\n.....\n..##.\n.....\n';
const exampleInput = fs.readFileSync('input/example.txt', 'utf8');
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    expect(plant.parseLine('.##..')).to.eql([false, true, true, false, false]);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {y: -1, x: 2},
      {y: -1, x: 3},
      {y: -2, x: 2},
      {y: -4, x: 2},
      {y: -4, x: 3},
    ];
    expect(plant.parse(smallExInput)).to.eql(expected);
  });
});
describe('min/max tests', () => {
  it('should find min/max ranges correctly', () => {
    const elves = plant.parse(smallExInput);
    const expected = {
      min: {y: -1, x: 2},
      max: {y: -4, x: 3},
    };
    expect(plant.minMax(elves)).to.eql(expected);
  });
});
describe('neighbor tests', () => {
  let map;
  before(() => {
    map = plant.makeMap(plant.parse(smallExInput));
  });
  it('should find neighbors correctly (-4,2)', () => {
    const expected = [
      {y: -4, x: 3},
    ];
    expect(plant.neighborElves({y: -4, x: 2}, map)).to.eql(expected);
  });
  it('should find neighbors correctly (-1,3)', () => {
    const expected = [
      {y: -1, x: 2},
      {y: -2, x: 2},
    ];
    expect(plant.neighborElves({y: -1, x: 3}, map)).to.eql(expected);
  });
  it('should find neighbors correctly (-2,2)', () => {
    const expected = [
      {y: -1, x: 2},
      {y: -1, x: 3},
    ];
    expect(plant.neighborElves({y: -2, x: 2}, map)).to.eql(expected);
  });
});
describe('round tests', () => {
  it('should perform first round correctly', () => {
    const elves = plant.parse(smallExInput);
    const expected = [
      '0,2',
      '0,3',
      '-2,2',
      '-3,3',
      '-4,2',
    ];
    const state = plant.initialState(elves);
    plant.doRound(state);
    expect(state.anyElfMoved, 'any elf moved').to.be.true;
    const actual = Object.values(state.map).map((elf) => `${elf.y},${elf.x}`);
    for (const elfKey of actual) {
      expect(expected.includes(elfKey), `new elf ${elfKey}`).to.be.true;
    }
  });
  it('should perform all rounds correctly (small)', () => {
    const elves = plant.parse(smallExInput);
    const expected = [
      '0,2',
      '-1,4',
      '-2,0',
      '-3,4',
      '-5,2',
    ];
    const state = plant.initialState(elves);
    plant.doRounds(state);
    expect(state.anyElfMoved, '! any elf moved').to.be.false;
    const actual = Object.values(state.map).map((elf) => `${elf.y},${elf.x}`);
    for (const elfKey of actual) {
      expect(expected.includes(elfKey), `final elf ${elfKey}`).to.be.true;
    }
    expect(plant.empties(state)).to.eql(25);
  });
  it('should perform 10 rounds correctly (large)', () => {
    const elves = plant.parse(exampleInput);
    const expected = [
      '-8,4', '2,4',  '-3,-2',
      '0,-1', '-8,1', '0,1',
      '-6,3', '-2,0', '-5,-1',
      '-1,3', '-3,5', '-6,1',
      '1,8',  '-2,9', '-5,8',
      '-8,7', '0,4',  '-2,6',
      '-6,6', '-3,6', '-4,3',
      '-4,2'
    ];
    const state = plant.initialState(elves);
    plant.doRounds(state, 10);
    expect(state.anyElfMoved, '! any elf moved').to.be.true;
    const actual = Object.values(state.map).map((elf) => `${elf.y},${elf.x}`);
    for (const elfKey of actual) {
      expect(expected.includes(elfKey), `final elf ${elfKey}`).to.be.true;
    }
    const expectedMinMax = {
      min: {y:  2, x: -2},
      max: {y: -8, x:  9},
    };
    expect(plant.minMax(Object.values(state.map))).to.eql(expectedMinMax);
    expect(plant.empties(state)).to.eql(110);
  });
  it('should find stopping round correctly (large)', () => {
    const elves = plant.parse(exampleInput);
    const state = plant.initialState(elves);
    plant.doRounds(state);
    expect(state.anyElfMoved, '! any elf moved').to.be.false;
    expect(state.round - 1).to.equal(20);
  });
});
