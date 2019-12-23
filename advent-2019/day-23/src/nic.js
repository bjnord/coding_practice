'use strict';
const intcode = require('../../shared/src/intcode');

class NIC
{
  /**
   * Build a new NIC from an input string.
   *
   * @param {string} input - the input string, an Intcode program
   * @param {number} address - the unique network address
   *
   * @return {NIC}
   *   Returns a new NIC class object.
   */
  constructor(input, address)
  {
    // private: our Intcode program
    this._program = input.trim().split(/,/).map((str) => Number(str));
    // private: our unique network address
    this._address = address;
  }
  /**
   * Run the NIC Intcode program until it halts.
   *
   * In the callbacks, a packet is an `object` with the following fields:
   * - `destAddress` - the destination address
   * - `x` - X value
   * - `y` - Y value
   *
   * @param {function} sendPacket - `sendPacket(packet, addr)` will be
   *   called when the NIC with address `addr` sends a packet (`addr` is the
   *   _source_ address, `packet.destAddress` is the _destination_)
   * @param {function} receivePacket - `receivePacket(addr)` will be called
   *   when the NIC with address `addr` wants to receive a packet - it
   *   should return a packet `object`, or `undefined` if none is waiting
   * @param {object} [iState={pc: 0, rb: 0}] - Intcode processor state at
   *   which to resume (from previous return of `run()`)
   *
   * @return {object}
   *   Returns the Intcode processor state when it halts.
   */
  run(sendPacket, receivePacket, iState = {pc: 0, rb: 0})
  {
    let sendingPacket = {}, receivedPacket = undefined, ioWait = false;
    // only do this once, the first time run() is called for this NIC:
    let sentAddress = (iState.pc > 0);
    // machine sends us packets of three values: destAddress, X, Y
    const storeValue = ((v) => {
      if (sendingPacket.x !== undefined) {
        //console.debug(`SV: [3] got Y=${v}, packet done`);
        sendingPacket.y = v;
        sendPacket(sendingPacket, this._address);  // don't betray our trust
        sendingPacket = {};
      } else if (sendingPacket.destAddress !== undefined) {
        //console.debug(`SV: [2] got X=${v}`);
        sendingPacket.x = v;
      } else {
        //console.debug(`SV: [1] got A=${v}`);
        sendingPacket.destAddress = v;
      }
    });
    // machine receives packets of two values: X, Y
    // (or -1 if no packets are waiting)
    const getValue = (() => {
      if (!sentAddress) {
        sentAddress = true;
        //console.debug(`GV: sending address ${this._address}`);
        return this._address;
      }
      if (!receivedPacket) {
        receivedPacket = receivePacket(this._address);  // we trust you to behave
      }
      if (!receivedPacket) {
        // every other time, need to halt Intcode so we can timeshare the
        // other NICs
        if (ioWait) {
          ioWait = false;
          //console.debug(`GV: sending undefined (no packet waiting)`);
          return undefined;
        } else {
          ioWait = true;
          //console.debug(`GV: sending -1 (no packet waiting)`);
          return -1;
        }
      } else if (receivedPacket.x === undefined) {
        const y = receivedPacket.y;
        receivedPacket = undefined;
        //console.debug(`GV [2] sending Y=${y}, packet done`);
        return y;
      } else {
        const x = receivedPacket.x;
        receivedPacket.x = undefined;
        //console.debug(`GV [1] sending X=${x}`);
        return x;
      }
    });
    return intcode.run(this._program, false, getValue, storeValue, iState);
  }
}
module.exports = NIC;
