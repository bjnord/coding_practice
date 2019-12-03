var expect = require('chai').expect;
var intcode = require('../src/intcode');
describe('intcode run tests', function() {
  it('should transform 1,0,0,0,99 to 2,0,0,0,99', function() {
    const program = [1,0,0,0,99];
    expect(intcode.run(program)).to.eql([2,0,0,0,99]);
  });
  it('should transform 2,3,0,3,99 to 2,3,0,6,99', function() {
    const program = [2,3,0,3,99];
    expect(intcode.run(program)).to.eql([2,3,0,6,99]);
  });
  it('should transform 2,4,4,5,99,0 to 2,4,4,5,99,9801', function() {
    const program = [2,4,4,5,99,0];
    expect(intcode.run(program)).to.eql([2,4,4,5,99,9801]);
  });
  it('should transform 1,1,1,4,99,5,6,0,99 to 30,1,1,4,2,5,6,0,99', function() {
    const program = [1,1,1,4,99,5,6,0,99];
    expect(intcode.run(program)).to.eql([30,1,1,4,2,5,6,0,99]);
  });
});
