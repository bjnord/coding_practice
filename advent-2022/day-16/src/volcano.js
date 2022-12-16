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
    this._currentValve = 'AA';
    this._timeLeft = 30;
  }
  valve(name)
  {
    return this._valves[name];
  }
  valves()
  {
    return Object.values(this._valves);
  }
  currentValve()
  {
    return this.valve(this._currentValve);
  }
  neighborValves()
  {
    return this.neighborValvesOf(this.currentValve());
  }
  neighborValvesOf(valve)
  {
    return valve.tunnels().map((name) => this.valve(name));
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
    this._currentValve = valveName;
    this._time = time;
  }
  openBestValve()
  {
    this._bestCandidate = {};
    this._bestCandidate[this.currentValve().name()] = {
      name: this.currentValve().name(),
      rateGain: 0,
      timeLeft: this._timeLeft - 1,
    };
    this._visitNeighborsOf(this.currentValve(), this._timeLeft);
    const sortedCandidates = Object.values(this._bestCandidate)
      .sort((a, b) => Math.sign(b.rateGain - a.rateGain));
    this._move(sortedCandidates[0].name, sortedCandidates[0].timeLeft);
    this.valve(sortedCandidates[0].name).open();
  }
  _unvisitedNeighborValvesOf(valve)
  {
    return this.neighborValvesOf(valve)
      .filter((valve) => !(valve.name() in this._bestCandidate));
  }
  _visitNeighborsOf(valve, timeLeft)
  {
    // don't bother unless we have one turn to move, one turn to open the
    // valve, and at least one turn of flow
    if (timeLeft < 3) {
      return;
    }
    // with all moves costing 1, BFS will find shortest path to each valve
    const unvisitedNeighbors = this._unvisitedNeighborValvesOf(valve);
    for (const neighbor of unvisitedNeighbors) {
      const rateGain = neighbor.isOpen() ? 0 : (neighbor.rate() * (timeLeft - 2));
      this._bestCandidate[neighbor.name()] = {
        name: neighbor.name(),
        rateGain,
        timeLeft: timeLeft - 2,
      };
    }
    for (const neighbor of unvisitedNeighbors) {
      this._visitNeighborsOf(neighbor, timeLeft - 1);
    }
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
