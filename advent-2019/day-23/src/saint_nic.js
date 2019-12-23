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
    if (count < 2) {
      throw new Error('NIC count must be 2 or more');
    }
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
    // private: the NAT packet (we keep one at most)
    this._natPacket = undefined;
    // private: the packet Y values the NAT has seen
    this._natSaw = {};
  }
  /**
   * Route packets between the NICs.
   *
   * @param {boolean} useNAT - should NAT routing be enabled?
   *
   * @return {object}
   *   Returns the final packet; if `useNAT=false` it's the first one with
   *   `destAddress=255`; if `useNAT=true` it's the first one pushed by the
   *   NAT with a Y value it has seen before.
   */
  routePackets(useNAT = false)
  {
    let finalPacket = undefined;
    const sendPacket = (packet/*, addr*/) => {
      //console.debug(`sendPacket(${addr}) called; packet:`);
      //console.dir(packet);
      if (packet.destAddress === 255) {
        if (useNAT) {
          // "The NAT remembers only the last packet it receives; that is,
          // the data in each packet it receives overwrites the NAT's
          // packet memory with the new packet's X and Y values."
          this._natPacket = packet;
        } else {
          finalPacket = packet;
        }
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
    for (let i = 0, idleCheck = 0; !finalPacket; i = ((i + 1) % this._count)) {
      //console.debug(`== RUN NIC[${i}] -- state:`);
      //console.dir(this._states[i]);
      this._states[i] = this._nics[i].run(sendPacket, receivePacket, this._states[i]);
      if (this._networkIsIdle()) {
        // the "3 times" check is due to the nature of my round-robining;
        // we want to make sure each NIC got a real -1 (and didn't iowait
        // when there was a packet waiting)
        if ((++idleCheck >= 3) && this._natPacket) {
          // "Once the network is idle, the NAT sends only the last packet
          // it received to address 0; this will cause the computers on the
          // network to resume activity."
          this._natPacket.destAddress = 0;
          this._packets[0].push(this._natPacket);
          //console.debug('idle; pushed packet to NIC 0:');
          //console.dir(this._natPacket);
          // "What is the first Y value delivered by the NAT to the computer
          // at address 0 twice in a row?"
          if (this._natSaw[this._natPacket.y]) {
            finalPacket = this._natPacket;
          } else {
            this._natSaw[this._natPacket.y] = true;
          }
          // back to busy mode
          this._natPacket = undefined;
          idleCheck = 0;
        }
      }
    }
    //console.debug('final packet:');
    //console.dir(finalPacket);
    return finalPacket;
  }
  _networkIsIdle()
  {
    return this._packets.every((q) => q.length === 0);
  }
}
module.exports = SaintNIC;
