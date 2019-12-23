'use strict';
const NIC = require('../src/nic');

class SaintNIC
{
  /**
   * Build a new array of NICs from an input string.
   *
   * @param {string} input - the input string, an Intcode program
   * @param {number} count - the number of NICs to build
   *
   * @return {SaintNIC}
   *   Returns a new SaintNIC class object.
   */
  constructor(input, count)
  {
    // FIXME validate count >= 2
    // private: the number of NICs we have
    this._count = count;
    // private: our NICs
    this._nics = [];
    // private: the packet queue for each NIC
    this._packets = [];
    // private: the Intcode processor state for each NIC
    this._states = [];
    for (let i = 0; i < this._count; i++) {
      this._nics.push(new NIC(input, i));
      this._packets.push([]);
      this._states.push({pc: 0, rb: 0});
    }
  }
  /**
   * Route packets between the NICs.
   *
   * @return {object}
   *   Returns the final packet (the one with `destAddress=255`).
   */
  routePackets()
  {
    let finalPacket = undefined;
    const sendPacket = (packet) => {
      //console.debug(`sendPacket() called; packet:`);  // TODO "by ${a}" would be helpful
      //console.dir(packet);
      if (packet.destAddress === 255) {
        finalPacket = packet;
      } else {
        this._packets[packet.destAddress].push(packet);
      }
    };
    const receivePacket = (addr) => {
      const queuedPacket = this._packets[addr].shift();
      //console.debug(`receivePacket(${addr}) called; queuedPacket:`);
      //console.dir(queuedPacket);
      return queuedPacket;
    };
    for (let i = 0; !finalPacket; i = ((i + 1) % this._count)) {
      //console.debug(`== RUN NIC[${i}] -- state:`);
      //console.dir(this._states[i]);
      this._states[i] = this._nics[i].run(sendPacket, receivePacket, this._states[i]);
    }
    //console.debug('final packet:');
    //console.dir(finalPacket);
    return finalPacket;
  }
}
module.exports = SaintNIC;
