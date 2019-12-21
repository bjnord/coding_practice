'use strict';
const AsciiIntcode = require('../../shared/src/ascii_intcode');
const PuzzleGrid = require('../../shared/src/puzzle_grid');

class Hull
{
  /**
   * Build a new hull from an input string.
   *
   * @param {string} input - the input string, an Intcode program (which
   *   will run the springdroid's springscript)
   * @param {boolean} [continuousVideo=false] - provide continuous video
   *   feed?
   *
   * @return {Hull}
   *   Returns a new Hull class object.
   */
  constructor(input, continuousVideo = false)
  {
    // private: our Intcode program
    this._program = input.trim().split(/,/).map((str) => Number(str));
    // private: the hull grid
    this._grid = new PuzzleGrid({
      0: {name: 'air', render: '.'},
      1: {name: 'hull', render: '#'},
    });
    // private: provide continuous video feed?
    this._continuousVideo = continuousVideo;
    // private: current springdroid [Y, X] position
    this._droidPos = undefined;
    // private: amount of hull damage
    this._heather = undefined;
    /**
     * status messages
     * @member {Array}
     */
    this.statusLines = [];
    /**
     * springdroid path ([Y, X] positions)
     * @member {Array}
     */
    this.path = [];
  }
  /**
   * amount of hull damage
   * @member {number}
   */
  get damage()
  {
    return this._heather;
  }
  /**
   * Run the springdroid Intcode program until it halts.
   *
   * @param {string} script - the springscript program to send
   */
  run(script)
  {
    const states = {
      '@':         {state: 'getPrompt', next: 'blank'},
      'blank':     {state: 'getLine', next: 'header'},
      'header':    {state: 'getLine', next: 'blank2'},
      'blank2':    {state: 'getLine', next: 'result'},
      'result':    {state: 'getLine', next: 'blank3'},
      'blank3':    {state: 'getLine', next: 'feed'},
      'feed':      {state: 'getVideo',  next: 'feed', nextIfNumber: '!'},
    };
    // machine sent us a newline-terminated prompt string
    // send the matching answer string (without newline)
    const handlePrompt = ((s) => {
      /* istanbul ignore else */
      if (s === 'Input instructions:\n') {
        return script.trim();
      } else {
        throw new Error(`handlePrompt: unhandled prompt string [${s.trim()}]`);
      }
    });
    // machine sent us a newline-terminated non-prompt string
    const handleLine = ((s) => {
      s = s.trim();
      /* istanbul ignore next */
      if (this._continuousVideo) {
        console.log(s);
      }
      if (s) {
        this.statusLines.push(s);
      }
    });
    // machine sent us a video frame
    const handleVideoFrame = ((f) => {
      //console.debug('== RAW FRAME: ==');
      //console.dir(f[0]);
      //console.debug(f.map((v) => String.fromCharCode(v)).join(''));
      processFrame(f);
      this.path.push(this._droidPos);
      /* istanbul ignore next */
      if (this._continuousVideo) {
        this._dumpFrame();
      }
    });
    // machine sent us a non-ASCII (numeric) value
    const handleNumber = ((v) => {
      // "if the springdroid successfully makes it across, it will use an
      // output instruction to indicate the amount of damage to the hull as
      // a single giant integer outside the normal ASCII range"
      this._heather = v;
    });
    // process one video frame
    const processFrame = ((frame) => {
      let y = 0, x = 0;
      frame.forEach((v) => {
        switch (v) {
        case 10:  // \n (go to next line)
          // ignore extra \n at beginning
          if (x > 0) {
            y++;
          }
          x = 0;
          break;
        case 46:  // . = air
          this._grid.set([y, x++], 0);
          break;
        case 35:  // # = hull
          this._grid.set([y, x++], 1);
          break;
        case 64:  // @ = springdroid
          this._droidPos = [y, x];
          this._grid.set([y, x++], 0);
          break;
        /* istanbul ignore next */
        default:
          throw new Error(`unknown video character ${v} [${String.fromCharCode(v)}] at [${y}, ${x}]`);
        }
      });
    });
    const machine = new AsciiIntcode(this._program, states);
    machine.run(handlePrompt, handleVideoFrame, handleNumber, handleLine);
  }
  /* istanbul ignore next */
  // private: dump video frame
  _dumpFrame()
  {
    const objects = {'@': this._droidPos};
    this._grid.dump(' ', objects);
    console.log(`springdroid position: [${this._droidPos}]`);
    console.log('');
  }
}
module.exports = Hull;
