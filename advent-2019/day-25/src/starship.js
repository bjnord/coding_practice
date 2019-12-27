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
    // private: known rooms
    this._rooms = {};
    this._rooms[this._state.location] = {location: this._state.location};
    // private: list of directions from origin to here during `search()`
    this._walkPath = [];
    // private: location of Security Checkpoint
    this._checkpointLocation = undefined;
    // private: list of directions from origin to Security Checkpoint
    this._checkpointPath = [];
    // private: direction from Security Checkpoint to TODO <room-name>
    this._sensorDir = undefined;
  }
  /**
   * Search the starship.
   *
   * @return {string}
   *   Returns the "password for the main airlock".
   */
  search()
  {
    /*
     * show our initial state
     */
    //if (!this._state.inventory()) {
    //  console.error(`MESSAGE: ${this._state.message}`);
    //  throw new Error(`search ShipState.inventory() failed`);
    //}
    //console.debug(`starting inventory: ${this._state.haveItems.join(', ')}`);
    //console.debug('');
    //this._state.dump('Origin');
    /*
     * walk the whole ship, picking up items as we go
     */
    this._walkPath = [];
    this._walk(this._state.location);
    if (!this._state.inventory()) {
      console.error(`MESSAGE: ${this._state.message}`);
      throw new Error('search ShipState.inventory() failed');
    }
    //console.debug(`inventory after walk: ${this._state.haveItems.join(', ')}`);
    //console.debug('');
    /*
     * move to the Security Checkpoint room (next to the sensor room)
     */
    this._checkpointPath.forEach((dir) => {
      if (!this._state.move(dir)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`search ShipState.move(${dir}) failed`);
      }
    });
    if (this._state.location !== this._checkpointLocation) {
      throw new Error(`at ${this._state.location} not ${this._checkpointLocation}`);
    }
    //this._state.dump('Combo Position');
    /*
     * play drop & take until we weigh the right amount
     */
    this._dropCombo();
    //if (!this._state.inventory()) {
    //  console.error(`MESSAGE: ${this._state.message}`);
    //  throw new Error(`search ShipState.inventory() failed`);
    //}
    //console.debug(`inventory after drop combo: ${this._state.haveItems.join(', ')}`);
    //console.debug('');
    return this._state.airlockPassword;
  }
  // private: drop/take all combinations of inventory objects
  _dropCombo()
  {
    const nItems = this._state.haveItems.length;
    for (let i = 1; i <= nItems; i++) {
      const combos = Combinatorics.combination(this._state.haveItems, i);
      combos.forEach((combo) => {
        this._dropAndPickUp(combo);
      });
      if (this._state.airlockPassword) {
        break;
      }
    }
  }
  _dropAndPickUp(items)
  {
    if (this._state.airlockPassword) {
      //console.debug(`don't try dropping ${items.join(', ')}`);
      return;
    }
    //console.debug(`try dropping ${items.join(', ')}`);
    items.forEach((item) => {
      if (!this._state.drop(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`search ShipState.drop(${item}) failed`);
      }
    });
    if (this._state.move(this._sensorDir)) {
      //console.debug(`airlockPassword = ${this._state.airlockPassword}`);
      return;
    }
    items.forEach((item) => {
      if (!this._state.take(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`search ShipState.take(${item}) failed`);
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
          this._checkpointPath = this._walkPath.slice();
          this._sensorDir = dir;
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
    for (let item = this._state.itemsHere.pop(); item; item = this._state.itemsHere.pop()) {
      // taking photons plunges us into darkness, and we suffer Grue death
      if (item === 'photons') {
      }
      // taking giant electromagnet paralyzes us
      else if (item === 'giant electromagnet') {
      }
      // taking infinite loop, you guessed it, causes an infinite loop
      else if (item === 'infinite loop') {
      }
      // taking molten lava is just a bad idea
      else if (item === 'molten lava') {
      }
      // taking escape pod flings us from the ship
      else if (item === 'escape pod') {
      }
      else if (!this._state.take(item)) {
        console.error(`MESSAGE: ${this._state.message}`);
        throw new Error(`_pickUpAll ShipState.take(${item}) failed`);
      }
    }
  }
}
module.exports = Starship;
