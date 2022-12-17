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
    // hash of Valve class objects, key = valve name
    // (this has all valves including 0-rate ones)
    this._valves = input.trim().split(/\n/)
      .map((line) => new Valve(line))
      .reduce((h, valve) => {
        h[valve.name()] = valve;
        return h;
      }, {});
    // hash of path lists, key = valve name
    // (this only has non-0-rate valves plus root AA)
    this._valvePaths = this.valves()
      .filter((valve) => this._isPathValve(valve))
      .map((valve) => {
        return [
          valve.name(),
          valve.tunnelNames().map((tunnelName) => {
            return this._tunnelPath(valve.name(), tunnelName);
          }),
        ]
      })
      .reduce((h, pathPair) => {
        h[pathPair[0]] = pathPair[1];
        return h;
      }, {});
    this._currentValveName = 'AA';
    this._timeLeft = 30;
  }
  _isPathValve(valve)
  {
    return (valve.name() === 'AA') || (valve.rate() > 0);
  }
  _tunnelPath(prevName, name)
  {
    for (let cost = 1; ; cost++) {
      const valve = this.valve(name);
      if (this._isPathValve(valve)) {
        return {cost, endName: name};
      }
      // 0-rate valves only have two tunnels; continue the path by taking
      // the one we didn't get here via
      const nextName = valve.tunnelNames()
        .find((tunnelName) => tunnelName !== prevName);
      prevName = name;
      name = nextName;
    }
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
    return this._valvePaths[valve.name()];
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
    const drew = {};
    for (const valve of this.valves()) {
      if (this._isPathValve(valve)) {
        for (const path of this.pathsOf(valve)) {
          const neighbor = this.valve(path.endName);
          if (!drew[`${valve.name()}${neighbor.name()}`] && !drew[`${neighbor.name()}${valve.name()}`]) {
            fs.writeSync(f, `  ${valve.name()}(${valve.label()})---|${path.cost}|${neighbor.name()}(${neighbor.label()})\n`);
            drew[`${valve.name()}${neighbor.name()}`] = true;
          }
        }
      }
    }
    fs.closeSync(f);
  }
}
module.exports = Volcano;
