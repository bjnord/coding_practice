'use strict';

class Valve
{
  /**
   * Build a new valve from an input line.
   *
   * @param {string} line - the input line (_e.g._
   *   `Valve BB has flow rate=13; tunnels lead to valves CC, AA`)
   *
   * @return {Valve}
   *   Returns a new Valve.
   */
  constructor(line)
  {
    const m = line.match(/^Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w\s,]+)$/);
    this._name = m[1];
    this._rate = parseInt(m[2]);
    this._tunnelNames = m[3].split(/,\s+/);
    this._opened = false;
  }
  name()
  {
    return this._name;
  }
  rate()
  {
    return this._rate;
  }
  currentRate()
  {
    return this._opened ? this._rate : 0;
  }
  tunnelNames()
  {
    return this._tunnelNames;
  }
  label()
  {
    return `${this._name} ${this._rate}`;
  }
  isOpen()
  {
    return this._opened;
  }
  isClosed()
  {
    return !this._opened;
  }
  open()
  {
    this._opened = true;
  }
}
module.exports = Valve;
