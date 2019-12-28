'use strict';
const AsciiIntcode = require('../../shared/src/ascii_intcode');
const TestAsciiIntcode = require('../../shared/src/test_ascii_intcode');

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
    let machine;
    if (input instanceof TestAsciiIntcode) {
      // this way of constructing is for testing with a test mock machine
      machine = input;
    } else {
      const states = {
        '@':        {state: 'getLine', next: 'message'},
        'message':  {state: 'getLine', next: 'message', chainIfMatch: 'prompt', match: /^Command\?/},
        'prompt':   {state: 'getPrompt', next: 'message'},
      };
      const program = input.trim().split(/,/).map((str) => Number(str));
      machine = new AsciiIntcode(program, states);
    }
    // private: our ASCII Intcode machine
    this._machine = machine;
    // private: our machine's processor state
    this._machineState = {pc: 0, rb: 0};
    // private: our memoized inventory
    this._inventory = undefined;
    /**
     * the airlock password
     * @member {string}
     */
    this.airlockPassword = undefined;
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
    this._inventory = undefined;  // clear memoization
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
   * - `.description` {string} - description of the current location
   * - `.doorsHere` {Array} - list of compass directions leading from the current location (strings)
   * - `.itemsHere` {Array} - list of items at the current location (strings)
   * - `.message` {string} - response to the previous command (if any)
   * - `.airlockPassword` {string} - the airlock password (if any)
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
      i = this._parseRobotVoice(lines, i);
    }
    /*
     * Otherwise, this is a state update (most remains the same):
     */
    else {
      i = this._parseInventory(lines, i);
      i = this._parseMessage(lines, i);
    }
    if (i < lines.length) {
      throw new Error(`parse unexpected line ${i}: ${lines[i].trim()}`);
    }
  }
  _parseRobotVoice(lines, i)
  {
    if (lines[i] && lines[i].match(/^A loud, robotic voice says.*ejected/)) {
      const message = lines[i];
      // output in this case has a double full state; we want the second one:
      while ((lines[++i] !== undefined) && !lines[i].match(/^==\s/)) {
        ;
      }
      this.parse(this._lines.slice(i));
      this.message = message;
      return this._lines.length;
    }
    if (lines[i] && lines[i].match(/^A loud, robotic voice says.*proceed/)) {
      lines.forEach((line) => {
        let m;
        if ((m = line.match(/You should be able to get in by typing (\d+)/))) {
          this.airlockPassword = m[1];
        }
      });
      // TODO after implementing this.messageDetail[] and removing throws,
      //      change this to "return i;" so the messages go into detail
      //      (and change the test to look for it)
      return this._lines.length;
    }
    return i;
  }
  _parseLocation(lines, i)
  {
    let m;
    if (!lines[i] || !(m = lines[i].match(/^==\s+(.*)\s==\s*$/))) {
      return i;
    }
    this.location = m[1].trim();
    return i+1;
  }
  // TODO after implementing this.messageDetail[] and removing throws,
  //      change this to return true if lines[i] === undefined
  _isBlankLine(lines, i)
  {
    return ((lines[i] !== undefined) && (lines[i].trim().length === 0));
  }
  _parseDescription(lines, i)
  {
    if (!lines[i]) {
      return i;
    }
    this.description = lines[i++].trim();
    if (this._isBlankLine(lines, i)) {
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
    if (this._isBlankLine(lines, i)) {
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
    if (this._isBlankLine(lines, i)) {
      return i+1;
    }
    throw new Error(`_parseItems unexpected line ${i}: ${lines[i].trim()}`);
  }
  _parseMessage(lines, i)
  {
    if (!lines[i]) {
      return i;
    }
    this.message = lines[i++].trim();
    if (this._isBlankLine(lines, i)) {
      return i+1;
    }
    throw new Error(`_parseMessage unexpected line ${i}: ${lines[i].trim()}`);
  }
  _parseInventory(lines, i)
  {
    if (lines[i] === "You aren't carrying any items.") {
      this._inventory = [];
      i++;
    } else if (lines[i] === 'Items in your inventory:') {
      this._inventory = [];
      while (lines[++i].match(/^-\s/)) {
        this._inventory.push(lines[i].trim().slice(2));
      }
    } else {
      return i;
    }
    if (this._isBlankLine(lines, i)) {
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
    if (this._lines[0].match(/^You take the [^.]+\.$/)) {
      if (this._lines.length > 2) {
        //this._lines.map((line) => {
        //  console.debug(`GOT LINE "${line}"`);
        //});
        this.message = this._lines[2];
        return false;  // something unexpected; counts as failed
      }
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
   * items in our inventory
   * @member {Array}
   */
  get inventory()
  {
    if (this._inventory) {  // memoized
      return this._inventory;
    }
    this._run('inv');
    //this._lines.map((line) => {
    //  console.debug(`GOT LINE "${line}"`);
    //});
    this.parse(this._lines);
    return this._inventory;
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
