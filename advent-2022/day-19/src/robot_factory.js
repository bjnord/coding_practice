'use strict';

class RobotFactory
{
  static minutesLimit()
  {
    return 24;
  }
  constructor(blueprint, debug)
  {
    this._blueprint = blueprint;
    this._minutesLeft = RobotFactory.minutesLimit();
    this._resources = {
      ore: 0,
      clay: 0,
      obsidian: 0,
      geode: 0,
    }
    this._robots = {
      ore: 1,
      clay: 0,
      obsidian: 0,
      geode: 0,
    }
    this._nowBuilding = undefined;
    this._debug = debug;
  }
  resources(resourceType)
  {
    return this._resources[resourceType];
  }
  haveResourcesToBuild(robotType)
  {
    // TODO this is a stub from minimal refactoring
    if (robotType !== 'clay') {
      return false;
    }
    return this._resources['ore'] >= this._blueprint.costs('clay').ore;
  }
  consumeResourcesToBuild(robotType)
  {
    // TODO this is a stub from minimal refactoring
    if (robotType === 'clay') {
      this._resources['ore'] -= this._blueprint.costs('clay').ore;
    } else {
      throw new SyntaxError('only clay supported for now');
    }
  }
  run()
  {
    if (this._minutesLeft < 1) {
      throw new SyntaxError('run() called with no time left');
    }
    const buildOptions = ['ore', 'clay', 'obsidian', 'geode']
      .filter((robotType) => this.haveResourcesToBuild(robotType));
    buildOptions.unshift('nothing');  // always an option
    // TODO here we would clone and do DFS
    return this.step(buildOptions[buildOptions.length - 1]);
  }
  minute()
  {
    return RobotFactory.minutesLimit() - this._minutesLeft + 1;
  }
  step(buildRobotType)
  {
    if (this._debug) {
      console.log(`== Minute ${this.minute()} ==`);
    }
    this.startBuilding(buildRobotType)
    this.collectResources()
    this.finishBuilding()
    this._minutesLeft--;
    if (this._debug) {
      console.log('');
    }
    if (this._minutesLeft > 0) {
      return this.run();
    } else {
      // end of recursion
      return this._resources['geode'];
    }
  }
  _an(robotType)
  {
    return (robotType[0] === 'o') ? 'an' : 'a';
  }
  _verb(robotType)
  {
    return (robotType === 'geode') ? 'crack' : 'collect';
  }
  startBuilding(robotType)
  {
    if (!robotType) {
      throw new SyntaxError('startBuilding() robotType required');
    } else if (robotType !== 'nothing') {
      this._nowBuilding = robotType;
      this.consumeResourcesToBuild(robotType);
      if (this._debug) {
        // FIXME this only works for single-resource robots
        console.log(`Spend ${this._blueprint.costs(robotType).ore} ore to start building ${this._an(robotType)} ${robotType}-${this._verb(robotType)}ing robot.`);
      }
    }
  }
  collectResources()
  {
    for (const robotType of ['ore', 'clay', 'obsidian', 'geode']) {
      const nRobots = this._robots[robotType];
      if (nRobots > 0) {
        const action = (nRobots === 1) ? `robot ${this._verb(robotType)}s` : `robots ${this._verb(robotType)}`;
        const nResource = nRobots;
        this._resources[robotType] += nResource;
        if (this._debug) {
          console.log(`${nRobots} ${robotType}-${this._verb(robotType)}ing ${action} ${nResource} ${robotType}; you now have ${this._resources[robotType]} ${robotType}.`);
        }
      }
    }
  }
  finishBuilding()
  {
    if (this._nowBuilding) {
      this._robots[this._nowBuilding]++;
      if (this._debug) {
        console.log(`The new ${this._nowBuilding}-${this._verb(this._nowBuilding)}ing robot is ready; you now have ${this._robots[this._nowBuilding]} of them.`);
      }
      this._nowBuilding = undefined;
    }
  }
}
module.exports = RobotFactory;
