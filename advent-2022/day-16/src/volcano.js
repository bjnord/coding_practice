'use strict';
const Valve = require('../src/valve');

class Volcano
{
  /**
   * Build a new volcano from an input string.
   *
   * @param {string} input - the input string (_e.g._ lines like
   *   `Valve BB has flow rate=13; tunnels lead to valves CC, AA`
   *   separated by `\n`)
   *
   * @return {Volcano}
   *   Returns a new Volcano.
   */
  constructor(input)
  {
    this._valves = input.trim().split(/\n/)
      .map((line) => new Valve(line))
      .reduce((graph, valve) => {
        graph[valve.name()] = valve;
        return graph;
      }, {});
  }
  valve(name)
  {
    return this._valves[name];
  }
}
module.exports = Volcano;
