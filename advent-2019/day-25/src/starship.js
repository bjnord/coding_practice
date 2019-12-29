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
  /***************************
   * MAJOR FUNCTION METHODS  *
   ***************************/
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
    this._walkPath = [];
    this._walkFromLocation(this._state.location);
    this.location = this._state.location;
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
      /* istanbul ignore if */
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
    this._dropCombo(dir);
    this.location = this._state.location;
    this.airlockPassword = this._state.airlockPassword;
  }
  /*******************************
   * DROP AND TAKE COMBO METHODS *
   *******************************/
  // private: drop/take all combinations of inventory objects
  _dropCombo(dir)
  {
    const items = this._state.inventory.slice();
    // readjust the list slightly for code coverage:
    const item = items.splice(4, 1);
    items.splice(3, 0, item);
    for (let i = 1; i <= items.length; i++) {
      // it goes faster when you have advance knowledge ;-)
      const c = ((i + 2) % items.length) + 1;
      const combos = Combinatorics.combination(items, c);
      combos.forEach((itemsCombo) => {
        this._dropAndMoveAndPickUp(itemsCombo, dir);
      });
    }
  }
  // private: try dropping a list of items and moving, picking them back
  // up at the end -- could OPTIMIZE: this would go faster if we only
  // took/dropped the difference between the current combo and the next
  _dropAndMoveAndPickUp(items, dir)
  {
    // short-circuit once we find the password:
    if (this._state.airlockPassword) {
      return;
    }
    // drop a combination of items:
    items.forEach((item) => {
      /* istanbul ignore if */
      if (!this._state.drop(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`_dropAndMoveAndPickUp ShipState.drop(${item}) failed`);
      }
    });
    // try moving:
    if (this._state.move(dir)) {
      // stop once we move successfully (we found the right weight):
      return;
    }
    // pick items back up for the next attempt:
    items.forEach((item) => {
      /* istanbul ignore if */
      if (!this._state.take(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`_dropAndMoveAndPickUp ShipState.take(${item}) failed`);
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
      /* istanbul ignore if */
      if (!this._state.take(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`_pickUpAll ShipState.take(${item}) failed`);
      }
    }
  }
  /***************************
   * WALKING-RELATED METHODS *
   ***************************/
  // private: walk recursively starting from `location`
  _walkFromLocation(location)
  {
    // pick up everything we can from each room:
    this._pickUpAll();
    // walk all directions from this room:
    const dirs = this._state.doorsHere.slice();
    dirs.forEach((dir) => {
      this._walkInDir(dir, location);
    });
  }
  // private: walk in the given direction from a room
  _walkInDir(dir, location)
  {
    // we already walked to this room:
    if (this._alreadyWalkedInDir(dir, location)) {
      return;
    }
    // if the move fails, it's probably the checkpoint; note its info:
    if (!this._state.move(dir)) {
      /* istanbul ignore else */
      if (this._state.message.match(/^A loud, robotic voice says.*ejected/)) {
        this._recordCheckpointInfo(dir, location);
      } else {
        throw new Error(`_walkInDir(${location}) move ${dir} failed: ${this._state.message}`);
      }
      return;
    }
    // the move succeeded; first update room entries for paths both ways:
    const backDir = this._updateRoomEntries(dir, location);
    // then do the recursive walk:
    this._walkStep(dir, location, backDir);
  }
  // private: continue the walk along the given path
  _walkStep(dir, location, backDir)
  {
    this._walkPath.push(dir);
    this._walkFromLocation(this._state.location);
    /* istanbul ignore if */
    if (!this._state.move(backDir)) {
      throw new Error(`_walkInDir(${location}) backtrack move ${backDir} failed: ${this._state.message}`);
    }
    this._walkPath.pop();
  }
  // private: did we already walk in given direction from a location?
  _alreadyWalkedInDir(dir, location)
  {
    /* istanbul ignore if */
    if (!this._rooms[location]) {
      throw new Error(`_alreadyWalkedInDir(${dir}, ${location}): no room found`);
    }
    return this._rooms[location][dir] ? true : false;
  }
  // private: record information about the checkpoint location
  _recordCheckpointInfo(dir, location)
  {
    this._checkpointLocation = location;
    this.checkpointPath = this._walkPath.slice();
    this.sensorDirection = dir;
  }
  // private: update room entries for a valid path between locations
  _updateRoomEntries(dir, location)
  {
    // create a new room entry for next location:
    const nextLocation = this._state.location;
    this._rooms[nextLocation] = {location: nextLocation};
    const nextRoom = this._rooms[nextLocation];
    // add dir pointer from current location's room to next location:
    const room = this._rooms[location];
    room[dir] = nextLocation;
    // add dir pointer from next location's room back to current location:
    const backDir = {north: 'south', south: 'north', west: 'east', east: 'west'}[dir];
    nextRoom[backDir] = location;
    return backDir;
  }
}
module.exports = Starship;
