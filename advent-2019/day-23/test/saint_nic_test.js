'use strict';
const expect = require('chai').expect;
const SaintNIC = require('../src/saint_nic');

describe('multiple NIC constructor tests', () => {
  it ('should throw an exception if count < 2', () => {
    const call = () => { new SaintNIC('99', 1); };
    expect(call).to.throw(Error, 'NIC count must be 2 or more');
  });
});
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
describe('multiple NIC tests, NAT mode [BJN simple 2-NIC example]', () => {
  let saintNic, lastPacket;
  before(() => {
    saintNic = new SaintNIC('3,90,1005,90,18,1101,0,1,91,4,91,104,1011,104,1,1105,1,22,1101,0,0,91,3,92,1007,92,0,94,1005,94,22,3,93,1002,93,2,93,1005,90,54,1007,93,65536,95,1005,95,51,1101,0,1,93,1105,1,72,1007,93,256,96,1005,96,68,1101,0,255,91,1105,1,72,1101,0,0,91,4,91,4,92,4,93,1105,1,22,99', 2);
    lastPacket = saintNic.routePackets(true);
  });
  it('should get the expected final result', () => {
    expect(lastPacket.destAddress).to.eql(0);
    expect(lastPacket.y).to.eql(512);
  });
});
