'use strict';
const expect = require('chai').expect;
const Blueprint = require('../src/blueprint');
const exampleInput = 'Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.\nBlueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.\n';
describe('parsing tests', () => {
  it('should parse one line correctly', () => {
    const costs = {
      ore: {ore: 4},
      clay: {ore: 2},
      obsidian: {ore: 3, clay: 14},
      geode: {ore: 2, obsidian: 7},
    };
    const blueprint = new Blueprint('Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.');
    expect(blueprint.number()).to.eql(1);
    for (const robotType in Object.keys(costs)) {
      expect(blueprint.costs(robotType)).to.eql(costs[robotType]);
    }
  });
  it('should parse a whole input set correctly', () => {
    const blueprints = Blueprint.parse(exampleInput);
    expect(blueprints.map((b) => b.number())).to.eql([1, 2]);
    expect(blueprints.map((b) => b.costs('ore').ore)).to.eql([4, 2]);
    expect(blueprints.map((b) => b.costs('geode').obsidian)).to.eql([7, 12]);
  });
});
