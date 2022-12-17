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
    this._currentValveName = 'AA';
    this._timeLeft = 30;
  }
  valve(valveName)
  {
    return this._valves[valveName];
  }
  valves()
  {
    return Object.values(this._valves);
  }
  currentValve()
  {
    return this.valve(this._currentValveName);
  }
  pathsOf(valve)
  {
    return valve.tunnelNames().map((valveName) => ({cost: 1, endName: valveName}));
  }
  closedValves()
  {
    return this.valves().filter((valve) => valve.isClosed());
  }
  totalRate()
  {
    return this.valves()
      .reduce((total, valve) => total + valve.currentRate(), 0);
  }
  _move(valveName, time)
  {
    this._currentValveName = valveName;
    this._time = time;
  }
  openBestValve()
  {
    this._bestCandidate = {};
    this._bestCandidate[this.currentValve().name()] = {
      valveName: this.currentValve().name(),
      rateGain: 0,
      timeLeft: this._timeLeft - 1,
    };
    this._visitPathsOf(this.currentValve(), this._timeLeft);
    const sortedCandidates = Object.values(this._bestCandidate)
      .sort((a, b) => Math.sign(b.rateGain - a.rateGain));
    console.debug('sorted best valve candidates:');
    console.dir(sortedCandidates);
    this._move(sortedCandidates[0].valveName, sortedCandidates[0].timeLeft);
    this.valve(sortedCandidates[0].valveName).open();
  }
  _unvisitedPathsOf(valve)
  {
    return this.pathsOf(valve)
      .filter((path) => !(path.endName in this._bestCandidate));
  }
  _visitPathsOf(valve, timeLeft)
  {
    // don't bother unless we have one turn to move, one turn to open the
    // valve, and at least one turn of flow
    if (timeLeft < 3) {
      return;
    }
    // with all moves costing 1, BFS will find shortest path to each valve
    const unvisitedPaths = this._unvisitedPathsOf(valve);
    for (const path of unvisitedPaths) {
      const neighbor = this.valve(path.endName);
      const rateGain = neighbor.isOpen() ? 0 : (neighbor.rate() * (timeLeft - path.cost - 1));
      this._bestCandidate[neighbor.name()] = {
        valveName: neighbor.name(),
        rateGain,
        timeLeft: timeLeft - path.cost - 1,
      };
    }
    for (const path of unvisitedPaths) {
      this._visitPathsOf(this.valve(path.endName), timeLeft - path.cost);
    }
  }
  writeGraph(filePath)
  {
    const f = fs.openSync(filePath, 'w');
    fs.writeSync(f, 'graph LR\n');
    for (const valve of this.valves()) {
      for (const path of this.pathsOf(valve)) {
        const neighbor = this.valve(path.endName);
        fs.writeSync(f, `  ${valve.name()}(${valve.label()})-->|${path.cost}|${neighbor.name()}\n`);
      }
    }
    fs.closeSync(f);
  }
}
module.exports = Volcano;
