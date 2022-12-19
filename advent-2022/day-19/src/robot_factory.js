'use strict';

class RobotFactory
{
  static minutesLimit()
  {
    return 24;
  }
  static robotTypes()
  {
    return ['nothing', 'ore', 'clay', 'obsidian', 'geode'];
  }
  constructor(blueprint, debug)
  {
    this._blueprint = blueprint;
    this._minutesLeft = RobotFactory.minutesLimit();
    this._resources = {
      nothing: 0,
      ore: 0,
      clay: 0,
      obsidian: 0,
      geode: 0,
    }
    this._robots = {
      nothing: 0,
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
      if (robotType !== 'nothing') {
        s += ` ${this._resources[robotType]} ${this._robots[robotType]}`;
      }
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
    if (robotType === 'nothing') {
      return true;
    }
    for (const [resource, cost] of Object.entries(this._blueprint.costs(robotType))) {
      if (this._resources[resource] < cost) {
        return false;
      }
    }
    return true;
  }
  consumeResourcesToBuild(robotType)
  {
    if (robotType === 'nothing') {
      return;
    }
    for (const [resource, cost] of Object.entries(this._blueprint.costs(robotType))) {
      this._resources[resource] -= cost;
      if (this._resources[resource] < 0) {
        throw new SyntaxError(`resource ${resource} went negative`);
      }
    }
  }
  /*
   * TODO this is a crude attempt at pruning that didn't really work
   */
  notEnoughOf(robotType)
  {
    // these robots should be built toward the end of the 24 minutes
    if ((this.minute <= 12) && (robotType === 'geode')) {
      return false;
    } else if ((this.minute <= 8) && (robotType === 'obsidian')) {
      return false;
    }
    // TODO these will probably only work for the example blueprints
    const enough = {
      nothing: 18,
      ore: 3,
      clay: 7,
      obsidian: 7,
      geode: 3,
    }
    return this._robots[robotType] < enough[robotType];
  }
  run()
  {
    if (this._minutesLeft < 1) {
      throw new SyntaxError('run() called with no time left');
    }
    const buildOptions = RobotFactory.robotTypes()
      .filter((robotType) => this.notEnoughOf(robotType))
      .filter((robotType) => this.haveResourcesToBuild(robotType));
    const state = this.state();
    let maxGeodes = -Number.MAX_SAFE_INTEGER;
    while (buildOptions.length > 0) {
      const buildOption = buildOptions.shift();
      // dynamic programming: see if we've been at this state before
      const stateOption = `${state} ${buildOption}`;
      let newGeodes = this._nGeodesAtState[stateOption];
      if (newGeodes === undefined) {
//      console.debug(`trying t=${this.minute()} step(${buildOption})`);
        if (buildOptions.length > 0) {
          const factory = this.clone();
          newGeodes = factory.step(buildOption);
        } else {
          newGeodes = this.step(buildOption);
        }
        this._nGeodesAtState[stateOption] = newGeodes;
      }
      maxGeodes = Math.max(maxGeodes, newGeodes);
      // FIXME DEBUG TEMP:
      if ((this._nGeodesAtState['MAX'] == undefined) || (this._nGeodesAtState['MAX'] < maxGeodes)) {
        console.debug(`MAX up to ${maxGeodes} [clone]`);
        this._nGeodesAtState['MAX'] = maxGeodes;
      }
    }
    return maxGeodes;
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
