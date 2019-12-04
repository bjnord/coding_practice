'use strict';
const expect = require('chai').expect;
const Wire = require('../src/wire');
describe('wire constructor tests', () => {
  it('should parse 4 segments correctly', () => {
    const wire = new Wire('R8,U5,L5,D3');
    expect(wire.segments).to.have.lengthOf(4);
    expect(wire.segments[0]).to.eql({yi:  0, xi:  1, count: 8});
    expect(wire.segments[1]).to.eql({yi: -1, xi:  0, count: 5});
    expect(wire.segments[2]).to.eql({yi:  0, xi: -1, count: 5});
    expect(wire.segments[3]).to.eql({yi:  1, xi:  0, count: 3});
  });
  it('should create a grid from 4 segments correctly', () => {
    const wire = new Wire('R8,U5,L5,D3');
    expect(wire.grid).to.be.an('object');
    expect(wire.grid['0,0']).to.be.undefined;
    expect(wire.grid['0,1']).to.be.equal(1);
    expect(wire.grid['0,8']).to.be.equal(8);
    expect(wire.grid['0,9']).to.be.undefined;
    expect(wire.grid['1,8']).to.be.undefined;
    expect(wire.grid['-1,8']).to.be.equal(9);
    expect(wire.grid['-5,8']).to.be.equal(13);
    expect(wire.grid['-6,8']).to.be.undefined;
    expect(wire.grid['-5,3']).to.be.equal(18);
    expect(wire.grid['-5,2']).to.be.undefined;
    expect(wire.grid['-3,3']).to.be.equal(20);
    expect(wire.grid['-2,3']).to.be.equal(21);
    expect(wire.grid['-1,3']).to.be.undefined;
  });
});
