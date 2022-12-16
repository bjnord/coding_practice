'use strict';
const fs = require('fs');
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
  valves()
  {
    return Object.values(this._valves);
  }
  closedValves()
  {
    return Object.values(this._valves)
      .filter((valve) => valve.isClosed());
  }
  totalRate()
  {
    return Object.values(this._valves)
      .reduce((total, valve) => total + valve.currentRate(), 0);
  }
  writeGraph(path)
  {
    const f = fs.openSync(path, 'w');
    fs.writeSync(f, 'graph LR\n');
    for (const valve of this.valves()) {
      for (const tunnel of valve.tunnels()) {
        fs.writeSync(f, `  ${valve.name()}(${valve.label()}) --> ${tunnel}\n`);
      }
    }
    fs.closeSync(f);
  }
}
module.exports = Volcano;
