'use strict';
const expect = require('chai').expect;
const AsciiIntcode = require('../src/ascii_intcode');

describe('ASCII intcode constructor tests', () => {
  it('should throw exception if initial "@" state is not provided', () => {
    const program = [99];
    const states = {
      'message':  {state: 'getLine', next: 'prompt'},
      'prompt':   {state: 'getPrompt', next: 'message'},
    };
    const call = () => { new AsciiIntcode(program, states); };
    expect(call).to.throw(Error, 'initial "@" entry not found in state graph');
  });
});
describe('ASCII intcode run tests', () => {
  it('should be chainable and resumeable', () => {
    const input = '104,49,104,10,104,65,104,63,104,10,3,100,3,101,104,50,104,10,104,51,104,10,104,66,104,63,104,10,3,100,3,101,104,52,104,10,104,53,104,10,104,54,104,10,104,67,104,63,104,10,3,100,3,101,104,55,104,10,99';
    const program = input.trim().split(/,/).map((str) => Number(str));
    const states = {
      '@':        {state: 'getLine', next: 'message'},
      'message':  {state: 'getLine', next: 'message', chainIfMatch: 'prompt', match: /\?/},
      'prompt':   {state: 'getPrompt', next: 'message'},
    };
    const lines = [], prompts = [];
    let commandNo = 0;
    // machine sent us a newline-terminated non-prompt string
    const handleLine = ((s) => {
      //console.debug(`in handleLine(${s.trim()})`);
      lines.push(s.trim());
    });
    // machine sent us a newline-terminated non-prompt string
    const handlePrompt = ((s) => {
      if ((++commandNo & 0x1) === 0x1) {
        //console.debug(`in handlePrompt(${s.trim()}), returning undefined`);
        return undefined;  // pause every other prompt
      }
      prompts.push(s.trim());
      const commandStr = ''+commandNo;
      //console.debug(`in handlePrompt(${s.trim()}), returning "${commandStr}"`);
      return commandStr;
    });
    const machine = new AsciiIntcode(program, states);
    let state = {pc: 0, rb: 0};
    while (commandNo < 6) {
      //console.debug(`w() commandNo=${commandNo} state:`);
      //console.dir(state);
      state = machine.run(handlePrompt, undefined, undefined, handleLine, state);
    }
    //console.debug(`END commandNo=${commandNo} state:`);
    //console.dir(state);
    expect(state.state).to.eql('halt');
    expect(lines).to.eql(['1', '2', '3', '4', '5', '6', '7']);
    expect(prompts).to.eql(['A?', 'B?', 'C?']);
  });
});
