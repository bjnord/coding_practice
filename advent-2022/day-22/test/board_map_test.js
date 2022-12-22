'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const BoardMap = require('../src/board_map');
const exmapleInput = fs.readFileSync('input/example.txt', 'utf8');
const exampleMapInput = exmapleInput.split('\n\n')[0];
describe('BoardMap constructor tests', () => {
  let map;
  before(() => {
    map = new BoardMap(exampleMapInput);
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
    const badColumnFn = () => { map.columnRange(16); };
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
    const badRowFn = () => { map.rowRange(12); };
    expect(badRowFn).to.throw(SyntaxError);
  });
  it('should clone a board correctly', () => {
    const clonedMap = map.clone();
    expect(clonedMap.columnRange(1)).to.eql([4, 7]);
    expect(clonedMap.rowRange(1)).to.eql([8, 11]);
    expect(clonedMap.cellIsFloor(0, 8), 'floor 0,8').to.be.true;
    expect(clonedMap.cellIsWall(0, 11), 'wall 0,11').to.be.true;
    expect(clonedMap.cellIsVoid(1, 1), 'void 1,1').to.be.true;
  });
});
describe('BoardMap cell tests', () => {
  let map;
  before(() => {
    map = new BoardMap(exampleMapInput);
  });
  it('floor cell test should return correct values', () => {
    expect(map.cellIsFloor(0, 0), '! floor 0,0').to.be.false;
    expect(map.cellIsFloor(0, 8), 'floor 0,8').to.be.true;
    expect(map.cellIsFloor(0, 11), '! floor 0,11').to.be.false;
    //
    expect(map.cellIsFloor(7, 11), 'floor 7,11').to.be.true;
    expect(map.cellIsFloor(8, 15), 'floor 8,15').to.be.true;
    expect(map.cellIsFloor(11, 15), 'floor 11,15').to.be.true;
  });
  it('wall cell test should return correct values', () => {
    expect(map.cellIsWall(0, 0), '! wall 0,0').to.be.false;
    expect(map.cellIsWall(0, 8), '! wall 0,8').to.be.false;
    expect(map.cellIsWall(0, 11), 'wall 0,11').to.be.true;
    //
    expect(map.cellIsWall(8, 11), 'wall 8,11').to.be.true;
    expect(map.cellIsWall(11, 14), 'wall 11,14').to.be.true;
  });
  it('void cell test should return correct values', () => {
    expect(map.cellIsVoid(0, 0), 'void 0,0').to.be.true;
    expect(map.cellIsVoid(0, 8), '! void 0,8').to.be.false;
    expect(map.cellIsVoid(0, 11), '! void 0,11').to.be.false;
    //
    expect(map.cellIsVoid(0, 12), 'void 0,12').to.be.true;
    expect(map.cellIsVoid(7, 12), 'void 7,12').to.be.true;
    expect(map.cellIsVoid(8, 7), 'void 8,7').to.be.true;
    expect(map.cellIsVoid(8, 16), 'void 8,16').to.be.true;
    expect(map.cellIsVoid(11, 7), 'void 11,7').to.be.true;
    expect(map.cellIsVoid(11, 16), 'void 11,16').to.be.true;
    expect(map.cellIsVoid(12, 0), 'void 12,0').to.be.true;
  });
  it('cell tests should return undefined for void cells', () => {
    expect(map.cellIsFloor(0, 12), 'X floor 0,12').to.be.undefined;
    expect(map.cellIsWall(0, 12), 'X wall 0,12').to.be.undefined;
    expect(map.cellIsFloor(12, 0), 'X floor 12,0').to.be.undefined;
    expect(map.cellIsWall(12, 0), 'X wall 12,0').to.be.undefined;
  });
});
describe('BoardMap constructor tests (pathological)', () => {
  it('should throw exception for invalid cell', () => {
    const badCellsInput = '...\n.#.\n?.#\n';
    const badCellsFn = () => { new BoardMap(badCellsInput); };
    expect(badCellsFn).to.throw(SyntaxError);
  });
  it('should throw exception for horizontal discontinuity', () => {
    const badHorizInput = '...   ...\n.#.   .#.\n...   ...\n';
    const badHorizFn = () => { new BoardMap(badHorizInput); };
    expect(badHorizFn).to.throw(SyntaxError);
  });
  it('should throw exception for horizontal discontinuity', () => {
    const badVertInput = '...\n.#.\n...\n   \n   \n   \n...\n.#.\n...\n';
    const badVertFn = () => { new BoardMap(badVertInput); };
    expect(badVertFn).to.throw(SyntaxError);
  });
});
describe('BoardMap face tests', () => {
  let map;
  before(() => {
    map = new BoardMap(exampleMapInput);
  });
  it('should get correct face values for positions (face 1)', () => {
    expect(map._face({y: 0, x: 8})).to.equal(1);
    expect(map._face({y: 3, x: 11})).to.equal(1);
  });
  it('should get correct face values for positions (face 2)', () => {
    expect(map._face({y: 4, x: 0})).to.equal(2);
    expect(map._face({y: 7, x: 3})).to.equal(2);
  });
  it('should get correct face values for positions (face 3)', () => {
    expect(map._face({y: 4, x: 4})).to.equal(3);
    expect(map._face({y: 7, x: 7})).to.equal(3);
  });
  it('should get correct face values for positions (face 4)', () => {
    expect(map._face({y: 4, x: 8})).to.equal(4);
    expect(map._face({y: 7, x: 11})).to.equal(4);
  });
  it('should get correct face values for positions (face 5)', () => {
    expect(map._face({y: 8, x: 8})).to.equal(5);
    expect(map._face({y: 11, x: 11})).to.equal(5);
  });
  it('should get correct face values for positions (face 6)', () => {
    expect(map._face({y: 8, x: 12})).to.equal(6);
    expect(map._face({y: 11, x: 15})).to.equal(6);
  });
  it('should get correct face values for positions (void)', () => {
    expect(map._face({y: 0, x: 0})).to.be.undefined;
    expect(map._face({y: 0, x: 7})).to.be.undefined;
    expect(map._face({y: 0, x: 15})).to.be.undefined;
    expect(map._face({y: 3, x: 12})).to.be.undefined;
    expect(map._face({y: 7, x: 15})).to.be.undefined;
    expect(map._face({y: 8, x: 0})).to.be.undefined;
    expect(map._face({y: 11, x: 0})).to.be.undefined;
    expect(map._face({y: 11, x: 7})).to.be.undefined;
  });
  it('should get correct face values for positions (invalid)', () => {
    expect(map._face({y: -1, x: 0})).to.be.undefined;
    expect(map._face({y: 0, x: -1})).to.be.undefined;
    expect(map._face({y: 0, x: 16})).to.be.undefined;
    expect(map._face({y: 12, x: 0})).to.be.undefined;
  });
});
