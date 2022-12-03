'use strict';
const expect = require('chai').expect;
const util = require('../src/util');
const a = {'a': 5, 'b': 2, 'c': 3, 'd': 4, 'e': 1};
describe('common key tests (2 hashes)', () => {
  it('should find no common keys correctly (disjoint)', () => {
    const b = {'i': 4, 'j': 1, 'k': 5, 'l': 3, 'm': 2};
    expect(util.commonKeys2(a, b)).to.eql([]);
    expect(util.commonKeys2(b, a)).to.eql([]);
  });
  it('should find no common keys correctly (empty hashes)', () => {
    const b = {};
    expect(util.commonKeys2(a, b)).to.eql([]);
    expect(util.commonKeys2(b, a)).to.eql([]);
    expect(util.commonKeys2(b, b)).to.eql([]);
  });
  it('should find one common key correctly', () => {
    const b = {'i': 4, 'h': 1, 'g': 5, 'f': 3, 'e': 2};
    expect(util.commonKeys2(a, b)).to.eql(['e']);
    expect(util.commonKeys2(b, a)).to.eql(['e']);
  });
  it('should find all common keys correctly', () => {
    const b = {'a': 4, 'b': 1, 'c': 5, 'd': 3, 'e': 2};
    expect(util.commonKeys2(a, b).sort()).to.eql(['a', 'b', 'c', 'd', 'e']);
    expect(util.commonKeys2(b, a).sort()).to.eql(['a', 'b', 'c', 'd', 'e']);
  });
});
describe('common key tests (list of hashes)', () => {
  it('should throw exception for less than 2 hashes', () => {
    const callWith0 = () => { util.commonKeys(); };
    expect(callWith0).to.throw(SyntaxError);
    const callWith1 = () => { util.commonKeys(a); };
    expect(callWith1).to.throw(SyntaxError);
  });
  it('should find no common keys correctly for 2 hashes', () => {
    const b = {'i': 4, 'j': 1, 'k': 5, 'l': 3, 'm': 2};
    expect(util.commonKeys(a, b)).to.eql([]);
    expect(util.commonKeys(b, a)).to.eql([]);
  });
  it('should find one common key correctly for 3 hashes', () => {
    const b = {'i': 4, 'h': 1, 'g': 5, 'f': 3, 'e': 2};
    const c = {'a': 2, 'f': 3, 'e': 1, 'y': 5, 'z': 4};
    expect(util.commonKeys(a, b, c)).to.eql(['e']);
    expect(util.commonKeys(b, c, a)).to.eql(['e']);
    expect(util.commonKeys(c, a, b)).to.eql(['e']);
  });
  it('should find three common keys correctly for 4 hashes', () => {
    const b = {'c': 4, 'd': 1, 'e': 5, 'f': 3, 'g': 2};
    const c = {'v': 2, 'e': 3, 'd': 1, 'c': 5, 'z': 4};
    const d = {'e': 3, 'c': 5, 'f': 1, 'j': 2, 'd': 4};
    expect(util.commonKeys(a, b, c, d).sort()).to.eql(['c', 'd', 'e']);
    expect(util.commonKeys(a, c, b, d).sort()).to.eql(['c', 'd', 'e']);
    expect(util.commonKeys(d, c, b, a).sort()).to.eql(['c', 'd', 'e']);
    expect(util.commonKeys(d, b, c, a).sort()).to.eql(['c', 'd', 'e']);
  });
});
