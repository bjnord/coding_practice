'use strict';
const AsciiIntcode = require('../../shared/src/ascii_intcode');

class ShipState
{
  /**
   * Build a state/interface object by "wrapping" an ASCII Intcode machine.
   *
   * This object becomes the interface to the ASCII Intcode machine. It
   * provides a way to send commands to the machine, and get current state
   * information (parsed from the machine's responses).
   *
   * @param {string} input - the input string, an Intcode program
   *
   * @return {ShipState}
   *   Returns a new ShipState class object.
   */
  constructor(input)
  {
    const states = {
      '@':        {state: 'getLine', next: 'message'},
      'message':  {state: 'getLine', next: 'message', chainIfMatch: 'prompt', match: /^Command\?/},
      'prompt':   {state: 'getPrompt', next: 'message'},
    };
    const program = input.trim().split(/,/).map((str) => Number(str));
    // private: our ASCII Intcode machine
    this._machine = new AsciiIntcode(program, states);
    // private: our machine's processor state
    this._machineState = {pc: 0, rb: 0};
    // get the initial state output from the machine
    this.move(undefined);
  }
  /*
   * private: Run the ASCII Intcode machine to:
   *   (1) send a command [except initial state]
   *   (2) receive output lines [containing new state information]
   *   (3) force an Intcode iowait
   * (The callbacks are carefully arranged to accomplish this order.)
   *
   * After sending and receiving, the ASCII Intcode machine will iowait
   * (waiting for the next command) and this method will return. The next
   * time it's called, the Intcode machine will resume in the exact same
   * context (as if it had never been interrupted).
   *
   * @param {string} command - the command to send, or `undefined` to send
   *   nothing [initial state]
   */
  _run(command)
  {
    // machine sent us a newline-terminated prompt string
    // send the next command (without newline)
    const handlePrompt = ((s) => {
      if (command) {
        this.lastCommand = command;
        command = undefined;
        //console.debug(`SENDING COMMAND "${this.lastCommand}"`);
        return this.lastCommand;  // (1)
      }
      /* istanbul ignore next */
      if (!s.match(/^Command\?/)) {
        throw new Error(`handlePrompt: unhandled prompt string [${s.trim()}]`);
      }
      return undefined;  // (3)
    });
    // machine sent us a newline-terminated non-prompt string
    const handleLine = ((s) => {
      s = s.trim();
      // ignore blank lines at beginning of output:
      if ((this._lines.length > 0) || (s.length > 0)) {
        this._lines.push(s);  // (2)
      }
    });
    this._lines = [];
    this._machineState = this._machine.run(handlePrompt, undefined, undefined, handleLine, this._machineState);
  }
  /**
   * Parse ASCII Intcode machine output lines to set the current state.
   *
   * State will be available from the following members/methods:
   * - `.location` {string} - current location
   * - `.description` {string} - description of current location
   * - `.doorsHere` {string} - compass directions leading from current location
   * - `.itemsHere` {string} - items at the current location
   * - `.message` {string} - usually a response to the previous command
   *
   * @param {Array} lines - the machine output lines
   */
  parse(lines)
  {
    let i = 0;
    i = this._parseLocation(lines, i);
    /*
     * If output contains a location, this is a whole new state:
     */
    if (i > 0) {
      this.message = undefined;
      i = this._parseDescription(lines, i);
      i = this._parseDoors(lines, i);
      i = this._parseItems(lines, i);
    }
    /*
     * Otherwise, this is a state update (most remains the same):
     */
    else {
      i = this._parseMessage(lines, i);
    }
    if (lines[i] && lines[i].match(/^A loud, robotic voice says/)) {
      this.message = lines[i];
    } else if (i < lines.length) {
      throw new Error(`parse unexpected line ${i}: ${lines[i].trim()}`);
    }
  }
  _parseLocation(lines, i)
  {
    let m;
    if (!(m = lines[i].match(/^==\s+(.*)\s==\s*$/))) {
      return i;
    }
    this.location = m[1].trim();
    return i+1;
  }
  _parseDescription(lines, i)
  {
    this.description = lines[i].trim();
    if (lines[++i].trim().length === 0) {
      return i+1;
    }
    throw new Error(`_parseDescription unexpected line ${i}: ${lines[i].trim()}`);
  }
  _parseDoors(lines, i)
  {
    this.doorsHere = [];
    if (lines[i] !== 'Doors here lead:') {
      return i;
    }
    while (lines[++i].match(/^-\s/)) {
      this.doorsHere.push(lines[i].trim().slice(2));
    }
    if (lines[i].trim().length === 0) {
      return i+1;
    }
    throw new Error(`_parseDoors unexpected line ${i}: ${lines[i].trim()}`);
  }
  _parseItems(lines, i)
  {
    this.itemsHere = [];
    if (lines[i] !== 'Items here:') {
      return i;
    }
    while (lines[++i].match(/^-\s/)) {
      this.itemsHere.push(lines[i].trim().slice(2));
    }
    if (lines[i].trim().length === 0) {
      return i+1;
    }
    throw new Error(`_parseItems unexpected line ${i}: ${lines[i].trim()}`);
  }
  _parseMessage(lines, i)
  {
    this.message = lines[i].trim();
    if (lines[++i].trim().length === 0) {
      return i+1;
    }
    throw new Error(`_parseMessage unexpected line ${i}: ${lines[i].trim()}`);
  }
  _parseInventory(lines)
  {
    this.haveItems = [];
    let i = 0;
    if (lines[i] === "You aren't carrying any items.") {
      if (lines[++i].trim().length === 0) {
        return i+1;
      }
      return i;  // hm
    } else if (lines[i] !== 'Items in your inventory:') {
      this.message = lines[i] ? lines[i].trim() : undefined;
      return i;
    }
    while (lines[++i].match(/^-\s/)) {
      this.haveItems.push(lines[i].trim().slice(2));
    }
    if (lines[i].trim().length === 0) {
      return i+1;
    }
    throw new Error(`_parseInventory unexpected line ${i}: ${lines[i].trim()}`);
  }
  /**
   * Move in the given direction.
   *
   * @param {string} direction - the direction in which to move; must be
   *   one of `north` `south` `west` `east`
   *
   * @return {boolean}
   *   Returns indication of whether the move was successful.
   */
  move(direction)
  {
    this._run(direction);
    //this._lines.map((line) => {
    //  console.debug(`GOT LINE "${line}"`);
    //});
    this.parse(this._lines);
    if (this.message && this.message.match(/^A loud, robotic voice says.*proceed/)) {
      this._lines.forEach((line) => {
        let m;
        if ((m = line.match(/You should be able to get in by typing (\d+)/))) {
          /**
           * the airlock password
           * @member {string}
           */
          this.airlockPassword = m[1];
        }
      });
      return true;
    }
    return this.message ? false : true;
  }
  /**
   * Pick up an item.
   *
   * @param {string} item - the item to pick up
   *
   * @return {boolean}
   *   Returns indication of whether the take was successful.
   */
  take(item)
  {
    this._run(`take ${item}`);
    if (this._lines.length > 2) {
      //this._lines.map((line) => {
      //  console.debug(`GOT LINE "${line}"`);
      //});
      return false;  // something unexpected; say failed for now
    }
    if (this._lines[0].match(/^You take the [^.]+\.$/)) {
      return true;
    }
    this.message = this._lines[0];
    return false;
  }
  /**
   * Drop an item.
   *
   * @param {string} item - the item to drop
   *
   * @return {boolean}
   *   Returns indication of whether the drop was successful.
   */
  drop(item)
  {
    this._run(`drop ${item}`);
    if (this._lines.length > 2) {
      //this._lines.map((line) => {
      //  console.debug(`GOT LINE "${line}"`);
      //});
      return false;  // something unexpected; say failed for now
    }
    if (this._lines[0].match(/^You drop the [^.]+\.$/)) {
      return true;
    }
    this.message = this._lines[0];
    return false;
  }
  /**
   * Get our inventory.
   */
  inventory()
  {
    this._run('inv');
    //this._lines.map((line) => {
    //  console.debug(`GOT LINE "${line}"`);
    //});
    return (this._parseInventory(this._lines) > 0);
  }
  /* istanbul ignore next */
  /**
   * Dump the current state.
   */
  dump(title = 'State')
  {
    const width = 132;
    title = (title.trim() + ' ').padEnd(width - 7, '-');
    console.log(`+-- ${title}--+`);
    console.log(`| LOCATION: ${this.location.padEnd(width - 14, ' ')} |`);
    console.log(`| DESCRIPTION: ${this.description.padEnd(width - 17, ' ')} |`);
    console.log(`| DOORS: ${this.doorsHere.join(', ').padEnd(width - 11, ' ')} |`);
    console.log(`| ITEMS: ${this.itemsHere.join(', ').padEnd(width - 11, ' ')} |`);
    console.log(`+${''.padEnd(width - 2, '-')}+`);
    console.log('');
  }
}
module.exports = ShipState;
