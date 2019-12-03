var expect = require('chai').expect;
var Wire = require('../src/wire');
describe('wire constructor tests', () => {
  it('should parse 4 segments correctly', () => {
    let wire = new Wire('R8,U5,L5,D3');
    expect(wire.segments).to.have.lengthOf(4);
    expect(wire.segments[0]).to.eql({dir: 'R', count: 8});
    expect(wire.segments[1]).to.eql({dir: 'U', count: 5});
    expect(wire.segments[2]).to.eql({dir: 'L', count: 5});
    expect(wire.segments[3]).to.eql({dir: 'D', count: 3});
  });
  it('should create a grid from 4 segments correctly', () => {
    let wire = new Wire('R8,U5,L5,D3');
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
