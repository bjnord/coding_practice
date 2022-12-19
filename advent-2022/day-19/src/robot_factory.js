'use strict';

class RobotFactory
{
  static minutesLimit()
  {
    return 24;
  }
  static robotTypes()
  {
    return ['ore', 'clay', 'obsidian', 'geode'];
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
    // dynamic programming state cache
    this._nGeodesAtState = {};
  }
  clone()
  {
    const clone = new RobotFactory(this._blueprint);
    clone._minutesLeft = this._minutesLeft;
    clone._resources = RobotFactory.robotTypes()
      .reduce((h, robotType) => {
        h[robotType] = this.resources(robotType);
        return h;
      }, {});
    clone._robots = RobotFactory.robotTypes()
      .reduce((h, robotType) => {
        h[robotType] = this.robots(robotType);
        return h;
      }, {});
    if (this._nowBuilding) {
      throw new SyntaxError('clone while building');
    }
    clone._nowBuilding = undefined;
    clone._debug = this._debug;
    // it's OK (and in fact beneficial) for this to be a reference:
    clone._nGeodesAtState = this._nGeodesAtState;
    return clone;
  }
  state()
  {
    let s = `${this._minutesLeft}`;
    for (const robotType of RobotFactory.robotTypes()) {
      s += ` ${this._resources[robotType]} ${this._robots[robotType]}`;
    }
    return s;
  }
  resources(resourceType)
  {
    return this._resources[resourceType];
  }
  robots(robotType)
  {
    return this._robots[robotType];
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
    const buildOptions = RobotFactory.robotTypes()
      .filter((robotType) => this.haveResourcesToBuild(robotType));
    buildOptions.unshift('nothing');  // always an option
    let maxGeodes = -Number.MAX_SAFE_INTEGER;
    while (buildOptions.length > 1) {
      const buildOption = buildOptions.shift();
      // dynamic programming: see if we've been at this state before
      let newGeodes = this._nGeodesAtState[this.state()];
      if (newGeodes === undefined) {
//      console.debug(`trying t=${this.minute()} step(${buildOption}) [clone]`);
        const factory = this.clone();
        newGeodes = factory.step(buildOption);
        this._nGeodesAtState[this.state()] = newGeodes;
      }
      maxGeodes = Math.max(maxGeodes, newGeodes);
    }
//  console.debug(`trying t=${this.minute()} step(${buildOptions[0]})`);
    const newGeodes = this.step(buildOptions[0]);
    return Math.max(maxGeodes, newGeodes);
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
    for (const robotType of RobotFactory.robotTypes()) {
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
