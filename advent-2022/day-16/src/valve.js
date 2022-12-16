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
    this._tunnels = m[3].split(/,\s+/);
  }
  name()
  {
    return this._name;
  }
  rate()
  {
    return this._rate;
  }
  tunnels()
  {
    return this._tunnels;
  }
}
module.exports = Valve;
