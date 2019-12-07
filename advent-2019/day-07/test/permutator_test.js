'use strict';
const expect = require('chai').expect;
const permutator = require('../src/permutator');
describe('permutator tests', () => {
  it('should throw an exception if choices list is empty', () => {
    const call = () => { permutator.permute([], 1); };
    expect(call).to.throw(Error, 'Empty choices list');
  });
  it('should throw an exception if nPicks is negative', () => {
    const call = () => { permutator.permute([1,2,3], -1); };
    expect(call).to.throw(Error, 'Invalid number of picks');
  });
  it('should throw an exception if nPicks is too big for choices list', () => {
    const call = () => { permutator.permute([1,2], 3); };
    expect(call).to.throw(Error, 'Invalid number of picks');
  });
  it('returns empty set if nPicks=0', () => {
    expect(permutator.permute([6,7,8], 0).size).to.eql(0);
  });
  it('returns Set of Arrays with size of nPicks', () => {
    const nPicks = 2;
    const result = permutator.permute([1,2,3], nPicks);
    expect(result instanceof Set).to.be.true;
    result.forEach((p) => {
      expect(Array.isArray(p)).to.be.true;
      expect(p.length).to.eql(nPicks);
    });
  });
  it('has the expected size [8 pick 2]', () => {
    expect(permutator.permute([1,2,3,4,5,6,7,8], 2).size).to.eql(56);  // 8! / 6!
  });
  it('has the expected size [4 pick 4]', () => {
    expect(permutator.permute(['one','two','three','four'], 4).size).to.eql(24);  // 4!
  });
  it('returns correct permutations [1 pick 1]', () => {
    const exp = new Set([[1]]);
    expect(permutator.permute([1], 1)).to.eql(exp);
  });
  it('returns correct permutations [2 pick 1]', () => {
    const exp = new Set([[1], [2]]);
    expect(permutator.permute([1, 2], 1)).to.eql(exp);
  });
  it('returns correct permutations [2 pick 2]', () => {
    const exp = new Set([[1, 2], [2, 1]]);
    expect(permutator.permute([1, 2], 2)).to.eql(exp);
  });
  it('returns correct permutations [3 pick 2]', () => {
    const exp = new Set([
      [1, 2], [1, 3],
      [2, 1], [2, 3],
      [3, 1], [3, 2],
    ]);
    expect(permutator.permute([1, 2, 3], 2)).to.eql(exp);
  });
  it('returns correct permutations [3 pick 3]', () => {
    const exp = new Set([
      [1, 2, 3], [1, 3, 2],
      [2, 1, 3], [2, 3, 1],
      [3, 1, 2], [3, 2, 1],
    ]);
    expect(permutator.permute([1, 2, 3], 3)).to.eql(exp);
  });
  it('returns correct permutations [4 pick 3]', () => {
    const exp = new Set([
      [1, 2, 3], [1, 3, 2], [1, 3, 4], [1, 4, 3], [1, 2, 4], [1, 4, 2],
      [2, 1, 3], [2, 3, 1], [2, 1, 4], [2, 4, 1], [2, 3, 4], [2, 4, 3],
      [3, 1, 2], [3, 2, 1], [3, 1, 4], [3, 4, 1], [3, 2, 4], [3, 4, 2],
      [4, 1, 2], [4, 2, 1], [4, 1, 3], [4, 3, 1], [4, 2, 3], [4, 3, 2],
    ]);
    expect(permutator.permute([1, 2, 3, 4], 3)).to.eql(exp);
  });
});
