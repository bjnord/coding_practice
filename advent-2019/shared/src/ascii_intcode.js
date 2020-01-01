'use strict';
const intcode = require('../../shared/src/intcode');

class AsciiIntcode
{
  /**
   * Build an ASCII-interfaced Intcode computer from an input string.
   *
   * The basic Intcode machine has two operations, IN and OUT, which can
   * transfer one integer value at a time. This class "wraps" the Intcode
   * machine with an interface that sends and receives lines of ASCII
   * characters to and from the Intcode machine, for Intcode programs that
   * use that type of interface. Each ASCII character is sent as its
   * decimal code (_e.g._ `A` is 65 and `\n` is 10).
   *
   * The interface needs a state table that defines the sequence of input
   * and output lines expected from the Intcode machine. `@` is the initial
   * state, and `!` is the end state. For example:
   *
   * ```
   * const states = {
   *   '@':         {state: 'getLine', next: 'blank'},
   *   'blank':     {state: 'getLine', next: 'question'},
   *   'question:'  {state: 'getPrompt', next: 'answer'},
   *   'answer':    {state: 'getLine', next: '!'},
   * };
   * ```
   *
   * This state table says the Intcode machine is expected to output two
   * lines, prompt for an input line, output one more line, and halt. The
   * state labels (`blank` `question` etc.) are user-chosen.
   *
   * The allowed states are as follows (see `run()` for information about
   * the callbacks):
   *
   * - `getLine` - the Intcode machine sends an ASCII line, and the
   *     `handleLine` callback will be called to deliver it
   * - `getPrompt` - the Intcode machine sends an ASCII prompt line,
   *     and the `handlePrompt` callback will be called to deliver it,
   *     and obtain the reply line
   * - `getVideo` - the Intcode machine sends a video frame (a series of
   *     ASCII lines ending with a blank line), and the `handleVideo`
   *     callback will be called to deliver it
   *
   * @param {Array} program - the Intcode program (list of integers)
   * @param {object} states - the ASCII interface state table
   *
   * @return {AsciiIntcode}
   *   Returns a new AsciiIntcode class object.
   */
  constructor(program, states)
  {
    // private: our Intcode program
    this._program = program;
    // private: our state table
    this._states = states;
    if (!(this._stateEntry = this._states['@'])) {
      throw new Error('AsciiIntcode: initial "@" entry not found in state graph');
    }
    // private: our current state
    this._state = this._stateEntry.state;
    // private: prompt string (in) buffer
    this._promptStr = '';
    // private: command string (out) buffer
    this._commandStr;
    // private: video frame buffer
    this._frame = [];
  }
  // private: move to next state
  _nextState(isNumber = false)
  {
    // FIXME RF Uncle Bob Martin would say, don't use function args like
    //       this; should be _nextState() and _nextStateNumber()
    const nextEntry = isNumber
      ? (this._stateEntry.nextIfNumber || this._stateEntry.next)
      : this._stateEntry.next;
    if ((this._state === 'done') || (nextEntry === '!')) {
      this._state = 'done';
      return;
    }
    if (!(this._stateEntry = this._states[nextEntry])) {
      throw new Error(`AsciiIntcode: next entry '${nextEntry}' not found in state graph`);
    }
    this._state = this._stateEntry.state;
  }
  // private: should we chain to a different state?
  _chainIfMatch(s)
  {
    const chainEntry = this._stateEntry.chainIfMatch;
    if (chainEntry && s.match(this._stateEntry.match)) {
      if (!(this._stateEntry = this._states[chainEntry])) {
        throw new Error(`AsciiIntcode: next entry '${chainEntry}' not found in state graph`);
      }
      this._state = this._stateEntry.state;
      if (this._state !== 'getPrompt') {
        throw new Error(`AsciiIntcode: bad chain state '${this._state}'; only 'getPrompt' supported`);
      }
      return true;
    } else {
      return false;
    }
  }
  /**
   * Run the Intcode program until it halts.
   *
   * @param {function} handlePrompt - will be called with one argument when
   *   the Intcode machine is sending a newline-terminated prompt string,
   *   **and** is expected to return the reply string - can return
   *   `undefined` if no reply is ready (which will cause the Intcode
   *   machine to `iowait`)
   * @param {function} handleVideoFrame - will be called with one argument
   *   when the Intcode machine is sending a video frame (a series of
   *   newline-terminated strings)
   * @param {function} handleNumber - will be called with one argument when
   *   the Intcode machine is sending a non-ASCII value (treat as a number)
   * @param {function} handleLine - will be called with one argument when
   *   the Intcode machine is sending a newline-terminated non-prompt line
   * @param {object} [iState={pc: 0, rb: 0}] - starting Intcode state
   *   (see `Intcode.run()` for details)
   *
   * @return {object}
   *   Returns the new Intcode state (see `Intcode.run()` for details).
   */
  run(handlePrompt, handleVideoFrame, handleNumber, handleLine, iState = {pc: 0, rb: 0})
  {
    // TODO RF arguments should be a handler map
    //         with keys matching the state names
    // machine called IN; send the next ASCII code to it
    const getValue = (() => {
      /*
       * transitioning from OUT to IN:
       */
      if (this._state === 'getPrompt') {
        //console.debug(`AsciiIntcode.getValue: switch to state=sendCommand`);
        if ((this._commandStr = handlePrompt(this._promptStr)) === undefined) {
          //console.debug(`AsciiIntcode.getValue: handlePrompt() returned undefined; iowait`);
          return undefined;  // force Intcode iowait
        }
        this._state = 'sendCommand';
        this._promptStr = '';
      }
      /*
       * handling IN:
       */
      if (this._state === 'sendCommand') {
        if (this._commandStr.length === 0) {
          this._nextState();
          //console.debug(`AsciiIntcode.getValue: sendCommand finished, new state=${this._state}`);
          return 10;
        }
        const v = this._commandStr.slice(0, 1).charCodeAt(0);
        this._commandStr = this._commandStr.slice(1, this._commandStr.length);
        //console.debug(`AsciiIntcode.getValue: send char ${v} [${(v == 10) ? '\\n' : String.fromCharCode(v)}], remainder=[${this._commandStr.replace(/\n/g, '\\n')}]`);
        return v;
      } else if (this._state === 'done') {
        //console.debug(`AsciiIntcode.getValue: done [no further input]`);
        return undefined;
      } else {
        throw new Error(`AsciiIntcode.getValue: unhandled state ${this._state}`);
      }
    });
    // machine called OUT; receive the next ASCII code from it
    const storeValue = ((v) => {
      if (v > 127) {
        handleNumber(v);
        this._nextState(true);
        //console.debug(`AsciiIntcode.storeValue: got number ${v}, new state=${this._state}`);
        return;
      }
      if (this._state === 'getVideo') {
        if ((v === 10) && (this._frame[this._frame.length-1] === 10)) {
          // double \n signals end of frame
          //console.debug(`AsciiIntcode.storeValue: got ${this._frame.length} video frame chars`);
          handleVideoFrame(this._frame);
          this._frame = [];
          this._nextState();
          //console.debug(`AsciiIntcode.storeValue: getVideo finished, new state=${this._state}`);
        } else {
          // accumulate video frame data
          this._frame.push(v);
        }
      } else if (this._state === 'getLine') {
        if (v === 10) {
          if (this._chainIfMatch(this._promptStr)) {
            this._promptStr += String.fromCharCode(v);
            //console.debug(`AsciiIntcode.storeValue: getLine finished, chained for line=[${this._promptStr.trim()}], new state=${this._state}`);
          } else {
            handleLine(this._promptStr);
            this._promptStr = '';
            this._nextState();
            //console.debug(`AsciiIntcode.storeValue: getLine finished, new state=${this._state}`);
          }
        } else {
          // accumulate line characters
          this._promptStr += String.fromCharCode(v);
        }
      } else if (this._state === 'getPrompt') {
        // accumulate prompt characters
        this._promptStr += String.fromCharCode(v);
        //console.debug(`AsciiIntcode.storeValue: got char ${v} [${(v == 10) ? '\\n' : String.fromCharCode(v)}], prompt now=[${this._promptStr.replace(/\n/g, '\\n')}]`);
      } else if (this._state === 'done') {
        //console.debug(`AsciiIntcode.storeValue: done [ignore output]`);
        return;
      } else {
        throw new Error(`AsciiIntcode.storeValue: got character ${v} while in unsupported state ${this._state}`);
      }
    });
    return intcode.run(this._program, false, getValue, storeValue, iState);
  }
}
module.exports = AsciiIntcode;
