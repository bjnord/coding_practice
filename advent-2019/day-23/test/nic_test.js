'use strict';
const expect = require('chai').expect;
const NIC = require('../src/nic');

describe('NIC tests [BJN simple 1-NIC example]', () => {
  let nic, packets, state, yResult;
  before(() => {
    packets = [];
    const sendPacket = (p) => {
      if (p.destAddress === 255) {
        yResult = p.y;
      } else {
        packets.push(p);
      }
    };
    const receivePacket = () => packets.pop();
    // - get my address (store A in 50)
    // - send packet [X=5, Y=8] to my address
    // - receive packet (store X in 51, Y in 52)
    // - receive packet (none waiting)
    // - send packet [X=13, Y=21] to my address
    // - receive packet (store X in 51, Y in 52)
    // - send packet [X=34, Y=55] to address 255
    // - halt
    nic = new NIC('3,50,4,50,104,5,104,8,3,51,3,52,3,51,4,50,104,13,104,21,3,51,3,52,104,255,104,34,104,55,99', 0);
    state = nic.run(sendPacket, receivePacket);
  });
  it('should have last packet in addresses 51 and 52', () => {
    expect(nic._program[51]).to.eql(13);
    expect(nic._program[52]).to.eql(21);
  });
  it('should finish the Intcode program', () => {
    expect(state.state).to.eql('halt');
  });
  it('should return Y=55 for final result', () => {
    expect(yResult).to.eql(55);
  });
});
