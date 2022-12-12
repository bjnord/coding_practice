'use strict';
const expect = require('chai').expect;
const hill = require('../src/hill');
const exampleInput = 'Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const expect1 = {
      start: 0,
      heights: [1, 1, 2, 17, 16, 15, 14, 13],
    };
    expect(hill.parseLine('Sabqponm')).to.eql(expect1);
    const expect3 = {
      end: 5,
      heights: [1, 3, 3, 19, 26, 26, 24, 11],
    };
    expect(hill.parseLine('accszExk')).to.eql(expect3);
  });
  it('should parse a whole input set correctly', () => {
    const expected = [
      {
        heights: [1, 1, 2, 17, 16, 15, 14, 13],
        start: 0,
      },
      {
        heights: [1, 2, 3, 18, 25, 24, 24, 12],
      },
      {
        end: 5,
        heights: [1, 3, 3, 19, 26, 26, 24, 11],
      },
      {
        heights: [1, 3, 3, 20, 21, 22, 23, 10],
      },
      {
        heights: [1, 2, 4, 5, 6, 7, 8, 9],
      },
    ];
    expect(hill.parse(exampleInput)).to.eql(expected);
  });
});
