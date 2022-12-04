'use strict';
const expect = require('chai').expect;
const camp = require('../src/camp');
const exampleInput = '2-4,6-8\n2-3,4-5\n5-7,7-9\n2-8,3-7\n6-6,4-6\n2-6,4-8\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const expected = [
      {min: 2, max: 4},
      {min: 6, max: 8},
    ];
    expect(camp.parseLine('2-4,6-8')).to.eql(expected);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      [{min: 2, max: 4}, {min: 6, max: 8}],
      [{min: 2, max: 3}, {min: 4, max: 5}],
      [{min: 5, max: 7}, {min: 7, max: 9}],
      [{min: 2, max: 8}, {min: 3, max: 7}],
      [{min: 6, max: 6}, {min: 4, max: 6}],
      [{min: 2, max: 6}, {min: 4, max: 8}],
    ];
    expect(camp.parse(exampleInput)).to.eql(expected);
  });
});
describe('containment tests', () => {
  it('should detect no containment (disjoint)', () => {
    const assignmentPair = [
      {min: 2, max: 4},
      {min: 6, max: 8},
    ];
    expect(camp.fullContainment(assignmentPair)).to.equal(false);
  });
  it('should detect no containment (overlap)', () => {
    const assignmentPair = [
      {min: 5, max: 7},
      {min: 7, max: 9},
    ];
    expect(camp.fullContainment(assignmentPair)).to.equal(false);
  });
  it('should detect containment (1st contains 2nd)', () => {
    const assignmentPair = [
      {min: 3, max: 7},
      {min: 5, max: 7},
    ];
    expect(camp.fullContainment(assignmentPair)).to.equal(true);
  });
  it('should detect containment (2nd contains 1st)', () => {
    const assignmentPair = [
      {min: 2, max: 8},
      {min: 3, max: 7},
    ];
    expect(camp.fullContainment(assignmentPair)).to.equal(true);
  });
  it('should detect containment (2nd contains 1st at edge)', () => {
    const assignmentPair = [
      {min: 6, max: 6},
      {min: 4, max: 6},
    ];
    expect(camp.fullContainment(assignmentPair)).to.equal(true);
  });
});
