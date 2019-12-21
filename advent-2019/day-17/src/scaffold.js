'use strict';
const AsciiIntcode = require('../../shared/src/ascii_intcode');
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const Vacuum = require('../src/vacuum');
const pathAnalyzer = require('../src/path_analyzer');

class Scaffold
{
  /**
   * Build a new scaffold from an input string.
   *
   * @param {string} input - the input string, an Intcode program (which
   *   will output the scaffold map)
   *
   * @return {Scaffold}
   *   Returns a new Scaffold class object.
   */
  constructor(input)
  {
    // private: our Intcode program
    this._program = input.trim().split(/,/).map((str) => Number(str));
    // FYI: per Reddit post, address 438 is where the program keeps the
    // cumulative dust count (people are using it for visualizations)
    //console.debug(`address[438] = ${this._program[438]}`);

    this._initializeGridAndVacuum();
    /**
     * the amount of dust cleaned by the vacuum
     * @member {number}
     */
    this.dust = 0;
    // private: provide continuous video feed?
    this._continuousVideo = false;
    // private: functions from robot path analysis
    this._pathFunctions = undefined;
  }
  // private: initialize PuzzleGrid and Vacuum
  _initializeGridAndVacuum()
  {
    // private: the scaffold grid
    this._grid = new PuzzleGrid({
      0: {name: 'space', render: '.'},
      1: {name: 'scaffold', render: '#'},
      2: {name: 'intersection', render: 'O'},
    });
    // private: the vacuum robot
    this._vacuum = new Vacuum(this._grid);
  }
  /**
   * Run the grid-producing Intcode program until it halts.
   *
   * Modes are:
   * - `1` - finding intersections (Part One)
   * - `2` - vacuuming (Part Two)
   * - `3` - vacuuming (Part Two) with "continuous video feed"
   *
   * @param {number} [mode=1] - the operating mode
   */
  run(mode = 1)
  {
    if (mode > 1) {
      this._program[0] = 2;
      this._continuousVideo = (mode === 3);
    }
    /*
     * In mode 2/3, this state machine will go through the following steps:
     *
     * getVideo            // [initial video frame]
     * getPrompt           // "Main:\n"
     * sendCommand         // "A,B,...\n"
     * 3 times:            //
     *   getPrompt           // "Function _:\n" [_=A|B|C]
     *   sendCommand         // "R,8,...\n"
     * getPrompt           // "Continuous video feed?\n"
     * sendCommand         // "_\n" [_=y|n]
     * if mode=3, repeat:  //
     *   getVideo            // [intermediate video frames]
     * getVideo            // [final video frame]
     * done                // [ignore all further I/O]
     *
     * NB: The final answer (accumulated dust) is a special case handled
     * outside the state machine.
     */
    // machine sent us a newline-terminated prompt string
    // send the matching answer string (without newline)
    const handlePrompt = ((s) => {
      let m;
      if (s === 'Main:\n') {
        return this._pathFunctions[0];
      } else if ((m = s.match(/^Function (\w):\n$/))) {
        return this._pathFunctions[m[1].charCodeAt(0) - 64];  // A=1 etc.
      } else if (s === 'Continuous video feed?\n') {
        return this._continuousVideo ? 'y' : 'n';
      } else {
        throw new Error(`handlePrompt: unhandled prompt string [${s.trim()}]`);
      }
    });
    // machine sent us a video frame
    // FOR NOW, return the next state
    const handleVideoFrame = ((f) => {
      processFrame(f);
      if (this._continuousVideo) {
        this._dumpFrame();
      }
      // FOR NOW, return the next state
      if (mode === 1) {
        // we only get one video frame in this mode
        return 'done';
      } else if (!this._pathFunctions) {
        // this was the initial video frame
        this._analyzePath();
        return 'getPrompt';
      } else {
        // this was an intermediate/final video frame
        return this._continuousVideo ? 'getVideo' : 'done';
      }
    });
    // machine sent us a non-ASCII (numeric) value
    const handleNumber = ((v) => {
      // "Once it finishes the programmed set of movements, [...] the
      // cleaning robot will [...] report the amount of space dust it
      // collected as a large, non-ASCII value in a single output
      // instruction."
      this.dust = v;
    });
    // process one video frame
    const processFrame = ((frame) => {
      let y = 0, x = 0;
      this._initializeGridAndVacuum();
      frame.forEach((v) => {
        switch (v) {
        case 10:  // \n (go to next line)
          // ignore extra \n at beginning
          if (x > 0) {
            y++;
          }
          x = 0;
          break;
        case 46:  // . = outer space
          this._grid.set([y, x++], 0);
          break;
        case 35:  // # = scaffold
          this._grid.set([y, x++], 1);
          break;
        case 94:  // ^ = vacuum faces up
        case 118: // v = vacuum faces down
        case 60:  // < = vacuum faces left
        case 62:  // > = vacuum faces right
        case 88:  // X = vacuum is tumbling through space
          this._vacuum.set([y, x], String.fromCharCode(v));
          this._grid.set([y, x++], (v === 88) ? 0 : 1);
          break;
        /* istanbul ignore next */
        default:
          throw new Error(`unknown video character ${v} [${String.fromCharCode(v)}] at [${y}, ${x}]`);
        }
      });
    });
    const machine = new AsciiIntcode(this._program  /* TODO ,states */);
    machine.run(handlePrompt, handleVideoFrame, handleNumber);
    if (mode === 1) {
      this._findIntersections();
    }
  }
  // private: analyze robot path and store path functions
  _dumpFrame()
  {
    // TODO this isn't very useful, since dump() doesn't show the robot
    //      on the grid
    this._grid.dump();
    console.log(`vacuum pos: [${this._vacuum.position}] dir: [${this._vacuum.directionChar}]`);
    console.log('');
  }
  // private: analyze robot path and store path functions
  _analyzePath()
  {
    const gPath = pathAnalyzer.path(this._vacuum);
    this._pathFunctions = pathAnalyzer.functions(gPath);
  }
  // private: find scaffold intersections, setting them on the puzzle grid
  _findIntersections()
  {
    const scaffolds = this._grid.positionsWithType(1);
    const vacuum = new Vacuum(this._grid);
    const intersections = scaffolds.filter((pos) => {
      vacuum.set(pos, '^');
      return vacuum.atIntersection();
    });
    intersections.forEach((pos) => this._grid.set(pos, 2));
  }
  /**
   * Get the scaffold intersection positions.
   *
   * @return {Array}
   *   Returns scaffold intersection [Y, X] positions.
   */
  intersections()
  {
    return this._grid.positionsWithType(2);
  }
}
module.exports = Scaffold;
