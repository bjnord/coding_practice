'use strict';
const expect = require('chai').expect;
const BoardMap = require('../src/board_map');
const exampleInput = `        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.`;
describe('BoardMap constructor tests', () => {
  let map;
  before(() => {
    map = new BoardMap(exampleInput);
  });
  it('should return correct column ranges', () => {
    expect(map.columnRange(0)).to.eql([4, 7]);
    expect(map.columnRange(7)).to.eql([4, 7]);
    expect(map.columnRange(8)).to.eql([0, 11]);
    expect(map.columnRange(11)).to.eql([0, 11]);
    expect(map.columnRange(12)).to.eql([8, 11]);
    expect(map.columnRange(15)).to.eql([8, 11]);
  });
  it('should throw exception for invalid column', () => {
    const badColumnFn = () => { map.columnRange(16) };
    expect(badColumnFn).to.throw(SyntaxError);
  });
  it('should return correct row ranges', () => {
    expect(map.rowRange(0)).to.eql([8, 11]);
    expect(map.rowRange(3)).to.eql([8, 11]);
    expect(map.rowRange(4)).to.eql([0, 11]);
    expect(map.rowRange(7)).to.eql([0, 11]);
    expect(map.rowRange(8)).to.eql([8, 15]);
    expect(map.rowRange(11)).to.eql([8, 15]);
  });
  it('should throw exception for invalid row', () => {
    const badRowFn = () => { map.rowRange(12) };
    expect(badRowFn).to.throw(SyntaxError);
  });
  it('should return correct cell values', () => {
    expect(map.cellIsVoid(0, 0), `void 0,0`).to.be.true;
    expect(map.cellIsFloor(0, 0), `! floor 0,0`).to.be.false;
    expect(map.cellIsFloor(0, 8), `floor 0,14`).to.be.true;
    expect(map.cellIsVoid(0, 8), `! void 0,14`).to.be.false;
    expect(map.cellIsWall(0, 11), `wall 0,11`).to.be.true;
    expect(map.cellIsVoid(0, 12), `void 0,12`).to.be.true;
    expect(map.cellIsFloor(7, 11), `floor 7,11`).to.be.true;
    expect(map.cellIsVoid(7, 12), `void 7,12`).to.be.true;
    expect(map.cellIsVoid(8, 7), `void 8,7`).to.be.true;
    expect(map.cellIsWall(8, 11), `wall 8,11`).to.be.true;
    expect(map.cellIsFloor(8, 15), `floor 8,15`).to.be.true;
    expect(map.cellIsVoid(8, 16), `void 8,16`).to.be.true;
    expect(map.cellIsVoid(11, 7), `void 11,7`).to.be.true;
    expect(map.cellIsWall(11, 14), `wall 11,14`).to.be.true;
    expect(map.cellIsFloor(11, 15), `floor 11,15`).to.be.true;
    expect(map.cellIsVoid(11, 16), `void 11,16`).to.be.true;
  });
  it('should return undefined when testing void cell', () => {
    expect(map.cellIsFloor(0, 12), `X floor 0,12`).to.be.undefined;
    expect(map.cellIsWall(0, 12), `X wall 0,12`).to.be.undefined;
    expect(map.cellIsVoid(0, 12), `void 0,12`).to.be.true;
    expect(map.cellIsFloor(12, 0), `X floor 12,0`).to.be.undefined;
    expect(map.cellIsWall(12, 0), `X wall 12,0`).to.be.undefined;
    expect(map.cellIsVoid(12, 0), `void 12,0`).to.be.true;
  });
});
