'use strict';
const expect = require('chai').expect;
const Droid = require('../src/droid');
// TODO without a short example program, there's not much we can test;
//      it would be cool to work backward from the puzzle example
//      to an Intcode program that would output the correct values
//      (NOTE when implemented, remove run() "istanbul ignore next")
describe('droid constructor tests', () => {
  it('should initially have unknown oxygen system distance/position', () => {
    const droid = new Droid('99');
    expect(droid.oxygenSystemDistance).to.be.undefined;
    expect(droid.oxygenSystemPosition).to.be.undefined;
  });
});
describe('droid longest path length tests', () => {
  it('should throw an exception if maze is unexplored', () => {
    const unrunDroid = new Droid('99');
    const call = () => { unrunDroid.longestPathLengthFrom([0, 0]); };
    expect(call).to.throw(Error, 'maze must first be explored with run()');
  });
  it('should find the longest path [puzzle example]', () => {
    //  ##   
    // #..## 
    // #.#:.#
    // #.@.# 
    //  ###  
    const droid = new Droid('99');
    const example = new Map([
      /* */         ['-2,-2', 0], ['-2,-1', 0],
      ['-1,-3', 0], ['-1,-2', 1], ['-1,-1', 1], ['-1,0',  0], ['-1,1',  0],
      ['0,-3',  0], ['0,-2',  1], ['0,-1',  0], ['0,0',   1], ['0,1',   1], ['0,2',   0],
      ['1,-3',  0], ['1,-2',  1], ['1,-1',  2], ['1,0',   1], ['1,1',   0],
      /* */         ['2,-2',  0], ['2,-1',  0], ['2,0',   0],
    ]);
    droid.setGrid(example);
    expect(droid.longestPathLengthFrom([1, -1])).to.eql(4);
  });
});
