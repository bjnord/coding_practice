'use strict';
const expect = require('chai').expect;
const ArcadeGame = require('../src/arcade_game');
describe('arcade game count tests', () => {
  let arcadeGame;
  before(() => {
    arcadeGame = new ArcadeGame('104,1,104,2,104,3,104,6,104,5,104,4,99');
    arcadeGame.run();
  });
  it('should find no blocks (2)', () => {
    expect(arcadeGame.countOf(2)).to.eql(0);
  });
  it('should find one horizontal paddle (3)', () => {
    expect(arcadeGame.countOf(3)).to.eql(1);
  });
  it('should find one ball (4)', () => {
    expect(arcadeGame.countOf(4)).to.eql(1);
  });
});
