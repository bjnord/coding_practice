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
    this._initializeMachine(input);
    this._initializeMembers();
    // get the initial state output from the machine:
    this.move(undefined);
  }
  _initializeMachine(input)
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
  }
  _initializeMembers()
  {
    // private: our memoized inventory
    this._inventory = undefined;
    /**
     * the current location
     * @member {string}
     */
    this.location = undefined;
    /**
     * description of the current location
     * @member {string}
     */
    this.description = undefined;
    /**
     * list of compass directions leading from the current location (strings)
     * @member {Array}
     */
    this.doorsHere = [];
    /**
     * list of items at the current location (strings)
     * @member {Array}
     */
    this.itemsHere = [];
    /**
     * response to the previous command (if it failed)
     * @member {string}
     */
    this.message = undefined;
    /**
     * further output detail (if any) (strings)
     * @member {Array}
     */
    this.messageDetail = [];
    /**
     * the airlock password
     * @member {string}
     */
    this.airlockPassword = undefined;
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
    // callback: machine sent us a newline-terminated prompt string
    // send the next command (without newline)
    const handlePrompt = ((s) => {
      if (command) {
        this.lastCommand = command;
        command = undefined;
        return this.lastCommand;  // (1)
      }
      /* istanbul ignore next */
      if (!s.match(/^Command\?/)) {
        throw new Error(`handlePrompt: unhandled prompt string [${s.trim()}]`);
      }
      return undefined;  // (3)
    });
    // callback: machine sent us a newline-terminated non-prompt string
    const handleLine = ((s) => {
      s = s.trim();
      // ignore blank lines at beginning of output:
      if ((this._lines.length > 0) || (s.length > 0)) {
        this._lines.push(s);  // (2)
      }
    });
    // make sure we fetch fresh state after command execution:
    this._clearMemoizations();
    this._lines = [];
    this._machineState = this._machine.run(handlePrompt, undefined, undefined, handleLine, this._machineState);
  }
  // private: clear any memoizations
  _clearMemoizations()
  {
    this._inventory = undefined;
  }
  /***************************
   * PARSING-RELATED METHODS *
   ***************************/
  // private: parse ASCII Intcode machine output to set the current state
  _parse(lines)
  {
    this.message = undefined;
    this.messageDetail = [];
    let i = this._parseLocation(lines, 0);
    // if output contains a location, this is a whole new state:
    if (i > 0) {
      i = this._parseNewState(lines, i);
    }
    // otherwise, this is a state update (most remains the same):
    else {
      i = this._parseStateUpdate(lines, i);
    }
    // at the end, `this.messageDetail` soaks up whatever extra lines remain
    if (i < lines.length) {
      this.messageDetail = lines.slice(i);
    }
  }
  // private: parse "full new state"-style lines
  //   this replaces all existing state info
  _parseNewState(lines, i)
  {
    // NB already got location
    i = this._parseDescription(lines, i);
    i = this._parseDoors(lines, i);
    i = this._parseItems(lines, i);
    i = this._parseRobotVoiceStop(lines, i);
    return this._parseRobotVoiceGo(lines, i);
  }
  // private: parse "state update"-style lines:
  //   this only updates selected state info
  _parseStateUpdate(lines, i)
  {
    i = this._parseInventory(lines, i);
    i = this._parseDropOrTake(lines, i);
    return this._parseMessage(lines, i);
  }
  /*
   * private: _parseXxx() methods
   *
   * These all follow the same pattern: They parse out whatever applies to
   * their type (if anything), starting at line `i`, and return `i` pointing
   * at the first line beyond what they took. If nothing applies to their
   * type, `i` is left unchanged. The `lines` array is _never_ changed.
   */
  _parseLocation(lines, i)
  {
    let m;
    if (!lines[i] || !(m = lines[i].match(/^==\s+(.*)\s==\s*$/))) {
      return i;
    }
    this.location = m[1].trim();
    return i+1;
  }
  _parseDescription(lines, i)
  {
    /* istanbul ignore next */
    if (!lines[i]) {
      throw new Error(`_parseDescription expected non-blank line ${i}`);
    }
    this.description = lines[i++].trim();
    /* istanbul ignore else */
    if (!lines[i]) {
      return i+1;
    } else {
      throw new Error(`_parseDescription unexpected line ${i}: ${lines[i].trim()}`);
    }
  }
  _parseDoors(lines, i)
  {
    this.doorsHere = [];
    /* istanbul ignore next */
    if (lines[i] !== 'Doors here lead:') {
      throw new Error(`_parseDoors expected "Doors here lead:" at line ${i}`);
    }
    while (lines[++i].match(/^-\s/)) {
      this.doorsHere.push(lines[i].trim().slice(2));
    }
    /* istanbul ignore else */
    if (!lines[i]) {
      return i+1;
    } else {
      throw new Error(`_parseDoors unexpected line ${i}: ${lines[i].trim()}`);
    }
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
    /* istanbul ignore else */
    if (!lines[i]) {
      return i+1;
    } else {
      throw new Error(`_parseItems unexpected line ${i}: ${lines[i].trim()}`);
    }
  }
  _parseRobotVoiceStop(lines, i)
  {
    if (lines[i] && lines[i].match(/^A loud, robotic voice says.*ejected/)) {
      const message = lines[i];
      i = this._parseSecondLocation(lines, i);
      this.message = message;
      return this._lines.length;  // force this parse() to ignore remainder
    }
    return i;
  }
  _parseSecondLocation(lines, i)
  {
    // output in this case has a double full state; we want the second one:
    while ((lines[++i] !== undefined) && !lines[i].match(/^==\s/)) {
      ;
    }
    // parse() again with second full state:
    this._parse(this._lines.slice(i));
    return i;
  }
  _parseRobotVoiceGo(lines, i)
  {
    if (lines[i] && lines[i].match(/^A loud, robotic voice says.*proceed/)) {
      lines.forEach((line) => {
        let m;
        if ((m = line.match(/You should be able to get in by typing (\d+)/))) {
          this.airlockPassword = m[1];
        }
      });
    }
    return i;
  }
  /* eslint-disable complexity */
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
    /* istanbul ignore else */
    if (!lines[i]) {
      return i+1;
    } else {
      throw new Error(`_parseInventory unexpected line ${i}: ${lines[i].trim()}`);
    }
  }
  /* eslint-enable complexity */
  _parseDropOrTake(lines, i)
  {
    if (this._lines[i] && this._lines[i].match(/^You (drop|take) the [^.]+\.$/)) {
      /* istanbul ignore else */
      if (!lines[++i]) {
        return i+1;
      } else {
        throw new Error(`_parseDropOrTake unexpected line ${i}: ${lines[i].trim()}`);
      }
    }
    return i;
  }
  _parseMessage(lines, i)
  {
    if (!lines[i]) {
      return i;
    }
    this.message = lines[i++].trim();
    /* istanbul ignore else */
    if (!lines[i]) {
      return i+1;
    } else {
      throw new Error(`_parseMessage unexpected line ${i}: ${lines[i].trim()}`);
    }
  }
  /***************************
   * ACTION-RELATED METHODS  *
   ***************************/
  // private: do an action and parse the resulting output
  _accomplish(command)
  {
    this._run(command);
    this._parse(this._lines);
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
    this._accomplish(direction);
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
    this._accomplish(`take ${item}`);
    return this.message ? false : true;
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
    this._accomplish(`drop ${item}`);
    return this.message ? false : true;
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
    this._accomplish('inv');
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
