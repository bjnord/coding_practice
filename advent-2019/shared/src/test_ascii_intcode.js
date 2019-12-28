'use strict';

class TestAsciiIntcode
{
  /**
   * Build a test ASCII-interfaced Intcode computer.
   *
   * This has the same interface as the `AsciiIntcode` class, but is a test
   * mock version that outputs groups of fixed lines.
   *
   * @param {Array} expectedCommands - the commands we expect to receive
   * @param {Array} responses - the response outputs to send - each one is an array
   *   of strings
   */
  constructor(expectedCommands, responses)
  {
    // private: our expected input commands
    this._expectedCommands = expectedCommands;
    // private: our expected input command index
    this._expectedCommandIndex = 0;
    // private: our output responses
    this._responses = responses;
    // private: our output response index
    this._responseIndex = 0;
  }
  /**
   * Run the (test mock) Intcode program until it halts.
   *
   * @param {function} handlePrompt - [not implemented in test mock]
   * @param {function} handleVideoFrame - [not implemented in test mock]
   * @param {function} handleNumber - [not implemented in test mock]
   * @param {function} handleLine - will be called when the Intcode
   *   computer has sent a newline-terminated non-prompt line
   * @param {object} [iState={pc: 0, rb: 0}] - initial Intcode state
   *   (see `Intcode.run()` for details)
   *
   * @return {object}
   *   Returns Intcode state (see `Intcode.run()` for details).
   */
  run(handlePrompt, handleVideoFrame, handleNumber, handleLine, iState = {pc: 0, rb: 0})
  {
    // don't prompt for command first time (when sending initial response)
    if ((this._responseIndex > 0) && this._expectedCommands[this._expectedCommandIndex]) {
      const command = handlePrompt('Command?\n');
      if (command !== this._expectedCommands[this._expectedCommandIndex]) {
        throw new Error(`TestAsciiIntcode expected command "${this._expectedCommands[this._expectedCommandIndex]}" but got "${command}"`);
      }
      this._expectedCommandIndex++;
    }
    this._responses[this._responseIndex].forEach((line) => {
      handleLine(`${line.trim()}\n`);
    });
    if (++this._responseIndex > this._responses.length) {
      this._responseIndex = 0;
    }
    return iState;
  }
}
module.exports = TestAsciiIntcode;
