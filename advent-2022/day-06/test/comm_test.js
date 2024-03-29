'use strict';
const expect = require('chai').expect;
const comm = require('../src/comm');
describe('start-of-packet marker tests', () => {
  it('should find first marker for example 1', () => {
    const example1 = 'mjqjpqmgbljsphdztnvjfqwrcgsmlb';
    expect(comm.firstPacketMarker(example1)).to.equal(7);
  });
  it('should find first marker for example 2', () => {
    const example2 = 'bvwbjplbgvbhsrlpgdmjqwftvncz';
    expect(comm.firstPacketMarker(example2)).to.equal(5);
  });
  it('should find first marker for example 3', () => {
    const example3 = 'nppdvjthqldpwncqszvftbrmjlhg';
    expect(comm.firstPacketMarker(example3)).to.equal(6);
  });
  it('should find first marker for example 4', () => {
    const example4 = 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg';
    expect(comm.firstPacketMarker(example4)).to.equal(10);
  });
  it('should find first marker for example 5', () => {
    const example5 = 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw';
    expect(comm.firstPacketMarker(example5)).to.equal(11);
  });
});
describe('start-of-message marker tests', () => {
  it('should find first marker for example 1', () => {
    const example1 = 'mjqjpqmgbljsphdztnvjfqwrcgsmlb';
    expect(comm.firstMessageMarker(example1)).to.equal(19);
  });
  it('should find first marker for example 2', () => {
    const example2 = 'bvwbjplbgvbhsrlpgdmjqwftvncz';
    expect(comm.firstMessageMarker(example2)).to.equal(23);
  });
  it('should find first marker for example 3', () => {
    const example3 = 'nppdvjthqldpwncqszvftbrmjlhg';
    expect(comm.firstMessageMarker(example3)).to.equal(23);
  });
  it('should find first marker for example 4', () => {
    const example4 = 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg';
    expect(comm.firstMessageMarker(example4)).to.equal(29);
  });
  it('should find first marker for example 5', () => {
    const example5 = 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw';
    expect(comm.firstMessageMarker(example5)).to.equal(26);
  });
});
