'use strict';
const expect = require('chai').expect;
const hill = require('../src/hill');
const exampleInput = 'Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi\n';
const exampleGrid = hill.parse(exampleInput);
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
    const expected = {
      height: 5,
      width: 8,
      start: [0, 0],
      end: [2, 5],
      rows: [
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
      ],
    };
    expect(exampleGrid).to.eql(expected);
  });
});
describe('neighbor position tests', () => {
  it('should find neighbors properly (interior)', () => {
    const expected = [[0, 1], [2, 1], [1, 0], [1, 2]];
    expect(hill.neighbors(exampleGrid, [1, 1])).to.eql(expected);
  });
  it('should find neighbors properly (top edge)', () => {
    const expected = [[1, 2], [0, 1], [0, 3]];
    expect(hill.neighbors(exampleGrid, [0, 2])).to.eql(expected);
  });
  it('should find neighbors properly (bottom edge)', () => {
    const expected = [[3, 3], [4, 2], [4, 4]];
    expect(hill.neighbors(exampleGrid, [4, 3])).to.eql(expected);
  });
  it('should find neighbors properly (left edge)', () => {
    const expected = [[1, 0], [3, 0], [2, 1]];
    expect(hill.neighbors(exampleGrid, [2, 0])).to.eql(expected);
  });
  it('should find neighbors properly (right edge)', () => {
    const expected = [[2, 7], [4, 7], [3, 6]];
    expect(hill.neighbors(exampleGrid, [3, 7])).to.eql(expected);
  });
});
