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
   */
  run(handlePrompt, handleVideoFrame, handleNumber)
  {
    let state = 'getVideo', nextState, promptStr = '', commandStr, frame = [];
    // machine called IN; send the next ASCII code to it
    const getValue = (() => {
      /*
       * transitioning from OUT to IN:
       */
      if (state === 'getPrompt') {
        // we've received a complete prompt; machine is waiting for reply
        // 1. choose what to send (`commandStr`)
        // 2. choose what to do after that (`nextState`)
        state = 'sendCommand';
        let m;
        if (promptStr === 'Main:\n') {
          commandStr = handlePrompt(promptStr);
          nextState = 'getPrompt';
        } else if ((m = promptStr.match(/^Function (\w):\n$/))) {
          commandStr = handlePrompt(promptStr);
          nextState = 'getPrompt';
        } else if (promptStr === 'Continuous video feed?\n') {
          commandStr = handlePrompt(promptStr);
          nextState = 'getVideo';
        } else {
          throw new Error(`AsciiIntcode getValue: unhandled prompt [${promptStr}]`);
        }
        promptStr = '';
      }
      /*
       * handling IN:
       */
      if (state === 'sendCommand') {
        if (commandStr.length === 0) {
          state = nextState;
          nextState = undefined;
          return 10;
        }
        const v = commandStr.slice(0, 1).charCodeAt(0);
        commandStr = commandStr.slice(1, commandStr.length);
        //console.debug(`AsciiIntcode getValue: send char ${v} [${String.fromCharCode(v)}], remainder=[${commandStr}]`);
        return v;
      } else if (state === 'done') {
        return undefined;
      } else {
        throw new Error(`AsciiIntcode getValue: unhandled state ${state}`);
      }
    });
    // machine called OUT; receive the next ASCII code from it
    const storeValue = ((v) => {
      if (v > 127) {
        handleNumber(v);
        state = 'done';
        return;
      }
      if (state === 'getVideo') {
        if ((v === 10) && (frame[frame.length-1] === 10)) {
          // double \n signals end of frame
          const tempHACK = handleVideoFrame(frame);
          frame = [];
          // change state
          state = tempHACK;
        } else {
          // accumulate video frame data
          frame.push(v);
        }
      } else if (state === 'getPrompt') {
        // accumulate prompt characters
        promptStr += String.fromCharCode(v);
      } else if (state === 'done') {
        return;
      } else {
        throw new Error(`AsciiIntcode storeValue: got character ${v} while in unsupported state ${state}`);
      }
    });
    intcode.run(this._program, false, getValue, storeValue);
  }
}
module.exports = AsciiIntcode;
