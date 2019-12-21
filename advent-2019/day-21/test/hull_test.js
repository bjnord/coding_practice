'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const Hull = require('../src/hull');

describe('hull tests [puzzle example]', () => {
  let hull;
  before(() => {
    const input = fs.readFileSync('input/input.txt', 'utf8');
    hull = new Hull(input);
    const script = 'NOT D J\nWALK\n';
    hull.run(script);
  });
  it('should fail to make it across', () => {
    expect(hull.statusLines.some((line) => line.match(/Didn't\smake\sit\sacross/))).to.be.true;
  });
  it('should take the expected path');
  it('should fail to report amount of hull damage', () => {
    expect(hull.damage).to.be.undefined;
  });
});
