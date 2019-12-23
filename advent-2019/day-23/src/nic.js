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
   * @param {function} sendPacket - `sendPacket(packet)` will be called when
   *   the NIC sends a packet
   * @param {function} receivePacket - `receivePacket()` will be called when
   *   the NIC wants to receive a packet; it should return a packet `object`
   *   or `undefined` if none is waiting
   */
  run(sendPacket, receivePacket)
  {
    let sendingPacket = {}, receivedPacket = undefined, sentAddress = false;
    // machine sends us packets of three values: destAddress, X, Y
    const storeValue = ((v) => {
      if (sendingPacket.x !== undefined) {
        //console.debug(`[3] got Y=${v}, packet done`);
        sendingPacket.y = v;
        sendPacket(sendingPacket);
        sendingPacket = {};
      } else if (sendingPacket.destAddress !== undefined) {
        //console.debug(`[2] got X=${v}`);
        sendingPacket.x = v;
      } else {
        //console.debug(`[1] got A=${v}`);
        sendingPacket.destAddress = v;
      }
    });
    // machine receives packets of two values: X, Y
    // (or -1 if no packets are waiting)
    const getValue = (() => {
      if (!sentAddress) {
        sentAddress = true;
        //console.debug(`sending address ${this._address}`);
        return this._address;
      }
      if (!receivedPacket) {
        receivedPacket = receivePacket();
      }
      if (!receivedPacket) {
        //console.debug(`sending -1 (no packet waiting)`);
        return -1;
      } else if (receivedPacket.x === undefined) {
        const y = receivedPacket.y;
        receivedPacket = undefined;
        //console.debug(`[2] sending Y=${y}, packet done`);
        return y;
      } else {
        const x = receivedPacket.x;
        receivedPacket.x = undefined;
        //console.debug(`[1] sending X=${x}`);
        return x;
      }
    });
    return intcode.run(this._program, false, getValue, storeValue);
  }
}
module.exports = NIC;
