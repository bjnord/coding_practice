'use strict';

class RobotFactory
{
  constructor(blueprint, debug)
  {
    this._blueprint = blueprint;
    this._minute = 1;
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
  run()
  {
    for (let t = 0; t < 24; t++) {
      this.step();
    }
  }
  step()
  {
    if (this._debug) {
      console.log(`== Minute ${this._minute} ==`);
    }
    this.startBuilding()
    this.collectResources()
    this.finishBuilding()
    this._minute++;
    if (this._debug) {
      console.log('');
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
  /*
   * TODO This will be the **key algorithm** that drives the factory.
   */
  startBuilding()
  {
    if (this._resources['ore'] >= this._blueprint.costs('clay').ore) {
      this._resources['ore'] -= this._blueprint.costs('clay').ore;
      if (this._debug) {
        console.log(`Spend ${this._blueprint.costs('clay').ore} ore to start building ${this._an('clay')} clay-${this._verb('clay')}ing robot.`);
      }
      this._nowBuilding = 'clay';
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
