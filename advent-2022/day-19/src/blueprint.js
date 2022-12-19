'use strict';

class Blueprint
{
  /**
   * Construct a list of blueprints from the puzzle input.
   *
   * @param {string} input - lines of puzzle input separated by `\n`
   *
   * @return {Array.Blueprint}
   *   Returns a list of blueprints.
   */
  static parse(input)
  {
    return input.trim().split(/\n/).map((line) => new Blueprint(line));
  }
  /**
   * Construct a blueprint from a line of puzzle input.
   *
   * @param {string} line - line of puzzle input
   *   (_e.g._ `Blueprint 1: Each ore robot costs 4 ore. Each [...]. Each geode robot costs 2 ore and 7 obsidian.`)
   */
  constructor(line)
  {
    const m = line.match(/^Blueprint (\d+): (.*)$/);
    this._number = parseInt(m[1]);
    const costs = m[2].split('. ').map((ea) => ea.trim());
    this._robots = {};
    for (const cost of costs) {
      const cm = cost.match(/^Each (\w+) robot costs ([^.]+)\.?$/);
      const robotType = cm[1];
      const resources = cm[2].split(/\s+and\s+/);
      this._robots[robotType] = {};
      for (const resource of resources) {
        const rm = resource.match(/^(\d+) (\w+)$/);
        this._robots[robotType][rm[2]] = parseInt(rm[1]);
      }
    }
  }
  number()
  {
    return this._number;
  }
  costs(robotType)
  {
    return this._robots[robotType];
  }
}
module.exports = Blueprint;
