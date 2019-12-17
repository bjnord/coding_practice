'use strict';
const expect = require('chai').expect;
const PuzzleGrid = require('../src/puzzle_grid');
describe('puzzle grid constructor tests', () => {
  // TODO
  // should ensure grid key is an object with >= 2 valid entries
});
describe('puzzle grid get/set tests', () => {
  // TODO
  // should throw exception if coordinates [Y, X] is not an Array
  // should throw exception if coordinate Y & X are not numbers
  // should return `undefined` for spaces without content yet
});
describe('puzzle grid get attribute tests', () => {
  // TODO
});
describe('puzzle grid render tests', () => {
  // TODO
  // render() should be dump() but return an Array of strings
});
describe('puzzle grid parse tests', () => {
  it('should ignore empty lines at the end', () => {
    // TODO
  });
  it('should not ignore empty lines in the middle', () => {
    // TODO
  });
});
describe('puzzle grid parse tests [Nethack example]', () => {
  const nethackLines = [
    ' ----------',
    '#...@...$.|',
    ' |...B....+',
    ' |.d......|',
    ' ----------',
  ];
  const nethackKey = {
    0: {name: 'floor', render: '.'},
    1: {name: 'vwall', render: '|'},
    2: {name: 'hwall', render: '-'},
    3: {name: 'door', render: '+'},
    4: {name: 'hall', render: '#'},
  };
  it('should parse the grid correctly [no callback]', () => {
    const nh = PuzzleGrid.from(nethackLines, nethackKey);
    //nh.dump('?');
    expect(nh.get([0, 0])).to.be.null;
    expect(nh.get([0, 1])).to.eql(2);
    expect(nh.get([0, 11])).to.be.undefined;  // off right edge
    expect(nh.get([1, 0])).to.eql(4);
    expect(nh.get([1, 2])).to.eql(0);
    expect(nh.get([2, 1])).to.eql(1);
    expect(nh.get([2, 10])).to.eql(3);
    expect(nh.get([5, 0])).to.be.undefined;  // off bottom
    // movables:
    expect(nh.get([1, 4])).to.be.null;  // player
    expect(nh.get([3, 3])).to.be.null;  // dog
  });
  it('should parse the grid correctly [with callback]', () => {
    // TODO
    // have callback return `null` for ' ' voids e.g. [0,0] [2,0]
    // have callback return 0 (floor) for moveables
    //    and set moveables{'@': [1, 4]} as it goes
    //    then expect(moveables).to.eql({...});
    //    plus verify floor for those squares
  });
  it('should parse the grid correctly [with offset]', () => {
    // TODO
    // same as "[no callback]" example, but values should be offset
  });
});
