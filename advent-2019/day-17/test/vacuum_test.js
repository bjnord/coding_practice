'use strict';
const expect = require('chai').expect;
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const Vacuum = require('../src/vacuum');

const testGridKey = {
  0: {name: 'space', render: '.'},
  1: {name: 'scaffold', render: '#'},
  2: {name: 'intersection', render: 'O'},
};
const testGridLines = [
  '.####.....',
  '....#.....',
  '..#######.',
  '..#.#.....',
  '..###.....',
];

describe('vacuum constructor tests', () => {
  it('should construct a vacuum correctly');  // TODO
});
describe('vacuum clone tests', () => {
  let testGrid, vacuum, vacuumClone;
  before(() => {
    testGrid = PuzzleGrid.from(testGridLines, testGridKey);
    vacuum = new Vacuum(testGrid, [2, 8], '>');
    vacuumClone = vacuum.clone();
  });
  it('should make a clone correctly', () => {
    expect(vacuumClone.position).to.eql([2, 8]);
    expect(vacuumClone.directionChar).to.eql('>');
  });
  it('should ensure the clone is deep', () => {
    vacuum._pos[0] = 3;
    vacuum._dir = 2;
    expect(vacuumClone.position).to.eql([2, 8]);
    expect(vacuumClone.directionChar).to.eql('>');
  });
});
describe('vacuum set tests', () => {
  it('should set vacuum position correctly');  // TODO
  it('should set vacuum direction correctly');  // TODO
});
describe('vacuum get position tests', () => {
  it('should get vacuum position correctly');  // TODO
});
describe('vacuum get direction tests', () => {
  it('should get vacuum direction correctly');  // TODO
});
describe('vacuum step tests', () => {
  it('should step correctly [various scenarios]');  // TODO
});
describe('vacuum is-intersection tests', () => {
  let testGrid, vacuum;
  before(() => {
    testGrid = PuzzleGrid.from(testGridLines, testGridKey);
    vacuum = new Vacuum(testGrid, [0, 1], '>');
  });
  it('should identify [1, 4] correctly as a non-intersection (corridor)', () => {
    vacuum.set([1, 4], 'v');
    expect(vacuum.atIntersection()).to.be.false;
  });
  it('should identify [0, 4] correctly as a non-intersection (corner)', () => {
    vacuum.set([0, 4], '>');
    expect(vacuum.atIntersection()).to.be.false;
  });
  it('should identify [2, 8] correctly as a non-intersection (dead end)', () => {
    vacuum.set([2, 8], '>');
    expect(vacuum.atIntersection()).to.be.false;
  });
  it('should identify [1, 1] correctly as a non-intersection (space)', () => {
    vacuum.set([1, 1], 'X');
    expect(vacuum.atIntersection()).to.be.false;
  });
  it('should identify [-1, 0] correctly as a non-intersection (void)', () => {
    vacuum.set([-1, 0], 'X');
    expect(vacuum.atIntersection()).to.be.false;
  });
  it('should identify [3, 3] correctly as a non-intersection (inside loop)', () => {
    vacuum.set([3, 3], 'X');
    expect(vacuum.atIntersection()).to.be.false;
  });
  it('should identify [2, 4] correctly as an intersection', () => {
    vacuum.set([2, 4], 'v');
    expect(vacuum.atIntersection()).to.be.true;
  });
});
