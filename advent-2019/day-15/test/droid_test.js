'use strict';
const expect = require('chai').expect;
const Droid = require('../src/droid');
describe('droid constructor tests', () => {
  it('should initially have unknown oxygen system distance/position', () => {
    const droid = new Droid('99');
    expect(droid.oxygenSystemDistance).to.be.undefined;
    expect(droid.oxygenSystemPosition).to.be.undefined;
  });
});
describe('droid run tests', () => {
  let runDroid;
  before(() => {
    //  ##   
    // #..## 
    // #.#:.#
    // #.@.# 
    //  ###  
    //
    // [see test/example* for details on the Intcode program:]
    runDroid = new Droid('3,70,9,70,2001,71,74,73,2001,72,78,74,1002,70,-1,70,9,70,2,73,100,83,1,83,74,83,9,83,1201,116,0,84,1002,83,-1,83,9,83,1006,84,49,1001,73,0,71,1001,74,0,72,4,84,1105,1,0,99,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,1,0,0,0,0,-1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,-1,0,0,-1,-1,-1,0,1,1,0,0,-1,0,1,0,1,1,0,0,1,2,1,0,-1,-1,0,0,0,-1,-1');
    runDroid.run();
  });
  it('should find the distance to the oxygen system [puzzle example]', () => {
    expect(runDroid.oxygenSystemDistance).to.eql(2);
  });
  it('should find the oxygen system position [puzzle example]', () => {
    expect(runDroid.oxygenSystemPosition).to.eql([1, -1]);
  });
});
describe('droid longest path length tests', () => {
  it('should throw an exception if maze is unexplored', () => {
    const unrunDroid = new Droid('99');
    const call = () => { unrunDroid.longestPathLengthFrom([0, 0]); };
    expect(call).to.throw(Error, 'maze must first be explored with run()');
  });
  it('should find the longest path from the oxygen system [puzzle example]', () => {
    const oxyDroid = new Droid('3,70,9,70,2001,71,74,73,2001,72,78,74,1002,70,-1,70,9,70,2,73,100,83,1,83,74,83,9,83,1201,116,0,84,1002,83,-1,83,9,83,1006,84,49,1001,73,0,71,1001,74,0,72,4,84,1105,1,0,99,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,1,0,0,0,0,-1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,-1,0,0,-1,-1,-1,0,1,1,0,0,-1,0,1,0,1,1,0,0,1,2,1,0,-1,-1,0,0,0,-1,-1');
    oxyDroid.run();
    expect(oxyDroid.longestPathLengthFrom(oxyDroid.oxygenSystemPosition)).to.eql(4);
  });
});
