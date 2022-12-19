'use strict';
const expect = require('chai').expect;
const Blueprint = require('../src/blueprint');
const RobotFactory = require('../src/robot_factory');
const exampleBlueprint1 = 'Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.';
const exampleBlueprint2 = 'Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.';
describe('Factory run tests', () => {
  it('should run correctly', () => {
    const blueprint = new Blueprint(exampleBlueprint1);
    const factory = new RobotFactory(blueprint);
    factory.run();
    expect(factory.resources('clay')).to.equal(121);
  });
});
