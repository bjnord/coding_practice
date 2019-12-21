'use strict';
const intcode = require('../../shared/src/intcode');

class AsciiIntcode
{
  /**
   * Build an ASCII-interfaced Intcode computer from an input string.
   *
   * TODO describe what that means (char-at-a-time as ASCII codes)
   *
   * TODO describe format of `states`
   *      - `@` is initial state, `!` is end state
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
      throw new Error("AsciiIntcode: initial '@' entry not found in state graph");
    }
    this._state = this._stateEntry.state;
  }
  // private: move to next state
  _nextState(isNumber = false)
  {
    // FIXME RF Uncle Bob Martin would say, don't use function args like
    //       this; should be _nextState() and _nextStateNumber()
    const next = isNumber
      ? (this._stateEntry.nextIfNumber || this._stateEntry.next)
      : this._stateEntry.next;
    if ((this._state === 'done') || (next === '!')) {
      this._state = 'done';
      return;
    }
    if (!(this._stateEntry = this._states[next])) {
      throw new Error(`AsciiIntcode: next entry '${next}' not found in state graph`);
    }
    this._state = this._stateEntry.state;
  }
  /**
   * Run the Intcode program until it halts.
   *
   * TODO describe callbacks
   *      - single argument (what Intcode has sent)
   *      - single return value (what should be sent back to Intcode)
   *
   * @param {function} handlePrompt - will be called when the Intcode
   *   computer has sent a newline-terminated prompt string
   * @param {function} handleVideoFrame - will be called when the Intcode
   *   computer has sent a video frame
   * @param {function} handleNumber - will be called when the Intcode
   *   computer has sent a non-ASCII value (treat as number)
   * @param {function} handleLine - will be called when the Intcode
   *   computer has sent a newline-terminated non-prompt line
   */
  run(handlePrompt, handleVideoFrame, handleNumber, handleLine)
  {
    // TODO RF arguments should be a handler map
    //         with keys matching the state names
    let promptStr = '', commandStr, frame = [];
    // machine called IN; send the next ASCII code to it
    const getValue = (() => {
      /*
       * transitioning from OUT to IN:
       */
      if (this._state === 'getPrompt') {
        //console.debug(`AsciiIntcode.getValue: switch to state=sendCommand`);
        this._state = 'sendCommand';
        commandStr = handlePrompt(promptStr);
        promptStr = '';
      }
      /*
       * handling IN:
       */
      if (this._state === 'sendCommand') {
        if (commandStr.length === 0) {
          this._nextState();
          //console.debug(`AsciiIntcode.getValue: sendCommand finished, new state=${this._state}`);
          return 10;
        }
        const v = commandStr.slice(0, 1).charCodeAt(0);
        commandStr = commandStr.slice(1, commandStr.length);
        //console.debug(`AsciiIntcode.getValue: send char ${v} [${(v == 10) ? '\\n' : String.fromCharCode(v)}], remainder=[${commandStr.replace(/\n/g, '\\n')}]`);
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
        if ((v === 10) && (frame[frame.length-1] === 10)) {
          // double \n signals end of frame
          //console.debug(`AsciiIntcode.storeValue: got ${frame.length} video frame chars`);
          handleVideoFrame(frame);
          frame = [];
          this._nextState();
          //console.debug(`AsciiIntcode.storeValue: getVideo finished, new state=${this._state}`);
        } else {
          // accumulate video frame data
          frame.push(v);
        }
      } else if (this._state === 'getLine') {
        if (v === 10) {
          handleLine(promptStr);
          promptStr = '';
          this._nextState();
          //console.debug(`AsciiIntcode.storeValue: getLine finished, new state=${this._state}`);
        } else {
          // accumulate line characters
          promptStr += String.fromCharCode(v);
        }
      } else if (this._state === 'getPrompt') {
        // accumulate prompt characters
        promptStr += String.fromCharCode(v);
        //console.debug(`AsciiIntcode.storeValue: got char ${v} [${(v == 10) ? '\\n' : String.fromCharCode(v)}], prompt now=[${promptStr.replace(/\n/g, '\\n')}]`);
      } else if (this._state === 'done') {
        //console.debug(`AsciiIntcode.storeValue: done [ignore output]`);
        return;
      } else {
        throw new Error(`AsciiIntcode.storeValue: got character ${v} while in unsupported state ${this._state}`);
      }
    });
    intcode.run(this._program, false, getValue, storeValue);
  }
}
module.exports = AsciiIntcode;
