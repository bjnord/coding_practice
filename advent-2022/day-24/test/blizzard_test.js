'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const blizzard = require('../src/blizzard');
const exampleInput = `#.#####
#.....#
#>....#
#.....#
#...v.#
#.....#
#####.#`;
describe('parsing tests', () => {
  it('should parse a whole input set correctly', () => {
    const expected = {
      height: 7,
      width: 7,
      startX: 1,
      endX: 5,
      blizzards: [
        {y: 2, x: 1, dir: {y: 0, x: 1}},
        {y: 4, x: 4, dir: {y: -1, x: 0}},
      ],
    };
    expect(blizzard.parse(exampleInput)).to.eql(expected);
  });
  it('should parse a whole input set correctly (complex example)', () => {
    const exampleInput2 = fs.readFileSync('input/example2.txt', 'utf8');
    const expected2 = {
      height: 6,
      width: 8,
      startX: 1,
      endX: 6,
      blizzards: [
        {y: 1, x: 1, dir: {y: 0, x: 1}},
        {y: 1, x: 2, dir: {y: 0, x: 1}},
        {y: 1, x: 4, dir: {y: 0, x: -1}},
        {y: 1, x: 5, dir: {y: 1, x: 0}},
        {y: 1, x: 6, dir: {y: 0, x: -1}},
        //
        {y: 2, x: 2, dir: {y: 0, x: -1}},
        {y: 2, x: 5, dir: {y: 0, x: -1}},
        {y: 2, x: 6, dir: {y: 0, x: -1}},
        //
        {y: 3, x: 1, dir: {y: 0, x: 1}},
        {y: 3, x: 2, dir: {y: -1, x: 0}},
        {y: 3, x: 4, dir: {y: 0, x: 1}},
        {y: 3, x: 5, dir: {y: 0, x: -1}},
        {y: 3, x: 6, dir: {y: 0, x: 1}},
        //
        {y: 4, x: 1, dir: {y: 0, x: -1}},
        {y: 4, x: 2, dir: {y: 1, x: 0}},
        {y: 4, x: 3, dir: {y: -1, x: 0}},
        {y: 4, x: 4, dir: {y: 1, x: 0}},
        {y: 4, x: 5, dir: {y: 1, x: 0}},
        {y: 4, x: 6, dir: {y: 0, x: 1}},
      ],
    };
    expect(blizzard.parse(exampleInput2)).to.eql(expected2);
  });
});
