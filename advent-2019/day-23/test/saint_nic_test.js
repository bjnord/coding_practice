'use strict';
const expect = require('chai').expect;
const SaintNIC = require('../src/saint_nic');

describe('multiple NIC tests [BJN simple 2-NIC example]', () => {
  let saintNic, lastPacket;
  before(() => {
    saintNic = new SaintNIC('3,60,1005,60,18,1101,0,1,61,4,61,104,1011,104,1,1105,1,22,1101,0,0,61,3,62,1007,62,0,64,1005,64,22,3,63,1002,63,2,63,1007,63,256,65,1005,65,48,1101,0,255,61,4,61,4,62,4,63,1105,1,22,99', 2);
    lastPacket = saintNic.routePackets();
  });
  it('should get the expected final result', () => {
    expect(lastPacket.destAddress).to.eql(255);
    expect(lastPacket.y).to.eql(256);
  });
});
