'use strict';
const Combinatorics = require('js-combinatorics');
const ShipState = require('../src/ship_state');

class Starship
{
  /**
   * Build a new starship from an input string.
   *
   * @param {string} input - the input string, an Intcode program
   *
   * @return {Starship}
   *   Returns a new Starship class object.
   */
  constructor(input)
  {
    // private: our current state/interface to the Intcode machine
    this._state = new ShipState(input);
    /**
     * current location
     * @member {string}
     */
    this.location = this._state.location;
    // private: known rooms
    this._rooms = {};
    this._rooms[this._state.location] = {location: this._state.location};
    // private: list of directions from origin to here during `search()`
    this._walkPath = [];
    // private: location of Security Checkpoint
    this._checkpointLocation = undefined;
    /**
     * list of compass directions from "Hull Breach" (starting position) to
     * "Security Checkpoint" (strings)
     * @member {Array}
     */
    this.checkpointPath = [];
    /**
     * compass direction from "Security Checkpoint" to "Pressure-Sensitive Floor"
     * @member {string}
     */
    this.sensorDirection = undefined;
    /**
     * the airlock password
     * @member {string}
     */
    this.airlockPassword = undefined;
  }
  /**
   * Search the whole starship.
   *
   * When finished, the following members will be set:
   * - `location`
   * - `checkpointPath`
   * - `sensorDirection`
   */
  search()
  {
    /*
     * show our initial state
     */
    //console.debug(`starting inventory: ${this._state.inventory.join(', ')}`);
    //console.debug('');
    //this._state.dump('Origin');
    /*
     * walk the whole ship, picking up items as we go
     */
    this._walkPath = [];
    this._walk(this._state.location);
    this.location = this._state.location;
    //console.debug(`inventory after walk: ${this._state.inventory.join(', ')}`);
    //console.debug('');
  }
  /**
   * Move along the given path.
   *
   * When finished, the following member will be set:
   * - `location`
   *
   * @param {Array} dirs - the compass directions to take
   */
  move(dirs)
  {
    dirs.forEach((dir) => {
      if (!this._state.move(dir)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`move ShipState.move(${dir}) failed`);
      }
    });
    this.location = this._state.location;
  }
  /**
   * Move in the given direction, after adjusting weight by taking and
   * dropping items.
   *
   * When finished, the following members will be set:
   * - `location`
   * - `airlockPassword`
   */
  moveThroughSensor(dir)
  {
    //this._state.dump('Combo Position');
    this._dropCombo(dir);
    //console.debug(`inventory after drop combo: ${this._state.inventory.join(', ')}`);
    //console.debug('');
    this.location = this._state.location;
    this.airlockPassword = this._state.airlockPassword;
    //console.debug(`airlockPassword = ${this.airlockPassword}`);
  }
  // private: drop/take all combinations of inventory objects
  _dropCombo(dir)
  {
    const items = this._state.inventory.slice();
    //console.debug(`we have ${items.length} items`);
    for (let i = 1; i <= items.length; i++) {
      // it goes faster when you have advance knowledge ;-)
      const c = ((i + 2) % items.length) + 1;
      //console.debug(`try dropping combinations of ${c} items`);
      const combos = Combinatorics.combination(items, c);
      combos.forEach((itemsCombo) => {
        this._dropAndMoveAndPickUp(itemsCombo, dir);
      });
      // stop once we find the password:
      if (this._state.airlockPassword) {
        break;
      }
    }
  }
  // private: try dropping a list of items and moving, picking them back up
  // at the end
  _dropAndMoveAndPickUp(items, dir)
  {
    // stop once we find the password:
    if (this._state.airlockPassword) {
      //console.debug(`don't try dropping ${items.join(', ')}`);
      return;
    }
    //console.debug(`try dropping ${items.join(', ')}`);
    items.forEach((item) => {
      if (!this._state.drop(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`_dropAndMoveAndPickUp ShipState.drop(${item}) failed`);
      }
    });
    // stop once we move successfully (we found the right weight):
    if (this._state.move(dir)) {
      return;
    }
    items.forEach((item) => {
      if (!this._state.take(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`_dropAndMoveAndPickUp ShipState.take(${item}) failed`);
      }
    });
  }
  // private: walk the whole ship recursively
  _walk(location)
  {
    this._pickUpAll();
    let room;
    /* istanbul ignore next */
    if (!(room = this._rooms[location])) {
      throw new Error(`_walk(${location}): no room found`);
    }
    const dirs = this._state.doorsHere.slice();
    dirs.forEach((dir) => {
      if (room[dir]) {
        //console.debug(`_walk(${location}): already walked ${dir} from here:`);
        //console.dir(room);
      } else if (!this._state.move(dir)) {
        if (this._state.message.match(/^A loud, robotic voice says.*ejected/)) {
          this._checkpointLocation = location;
          this.checkpointPath = this._walkPath.slice();
          this.sensorDirection = dir;
        } else {
          throw new Error(`_walk(${location}) move(${dir}) failed: ${this._state.message}`);
        }
      } else {
        const nextLocation = this._state.location;
        let nextRoom;
        if (!(nextRoom = this._rooms[nextLocation])) {
          this._rooms[nextLocation] = {location: nextLocation};
          nextRoom = this._rooms[nextLocation];
          //this._state.dump('Next Room');
        }
        room[dir] = nextLocation;
        //console.debug(`_walk(${location}): added dir=${dir} to this room:`);
        //console.dir(room);
        const backDir = {north: 'south', south: 'north', west: 'east', east: 'west'}[dir];
        nextRoom[backDir] = location;
        //console.debug(`_walk(${location}): added dir=${backDir} to next room:`);
        //console.dir(nextRoom);
        this._walkPath.push(dir);
        this._walk(nextLocation);
        if (!this._state.move(backDir)) {
          throw new Error(`_walk(${location}) backtrack move(${backDir}) failed: ${this._state.message}`);
        }
        this._walkPath.pop();
      }
    });
  }
  // private: pick up all objects we can
  _pickUpAll()
  {
    const toxicItems = {
      'photons': true,
      'molten lava': true,
      'giant electromagnet': true,
      'escape pod': true,
      'infinite loop': true,
    };
    for (let item = this._state.itemsHere.pop(); item; item = this._state.itemsHere.pop()) {
      // don't pick up items that cause death or paralysis:
      if (toxicItems[item]) {
        continue;
      }
      if (!this._state.take(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`_pickUpAll ShipState.take(${item}) failed`);
      }
    }
  }
}
module.exports = Starship;
