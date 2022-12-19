'use strict';
const expect = require('chai').expect;
const Blueprint = require('../src/blueprint');
const RobotFactory = require('../src/robot_factory');
const exampleBlueprint1 = 'Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.';
const exampleBlueprint2 = 'Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.';
describe('Factory run tests', () => {
  it('should run correctly (blueprint 1)', () => {
    const blueprint = new Blueprint(exampleBlueprint1);
    const factory = new RobotFactory(blueprint);
    const maxGeodes = factory.run();
    console.debug(`example blueprint 1 maxGeodes=${maxGeodes}`);
    expect(maxGeodes).to.equal(9);
  });
  it('should run correctly (blueprint 2)', () => {
    const blueprint = new Blueprint(exampleBlueprint2);
    const factory = new RobotFactory(blueprint);
    const maxGeodes = factory.run();
    console.debug(`example blueprint 2 maxGeodes=${maxGeodes}`);
    expect(maxGeodes).to.equal(12);
  });
});
