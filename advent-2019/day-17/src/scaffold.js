'use strict';
const PuzzleGrid = require('../../shared/src/puzzle_grid');
const intcode = require('../../shared/src/intcode');
const pathAnalyzer = require('../src/path_analyzer');

// private: map of directions to [dY, dX] offsets
const _offsets = {
  1: [-1, 0],  // up (north, -Y)
  2: [1, 0],   // down (south, +Y)
  3: [0, -1],  // left (west, -X)
  4: [0, 1],   // right (east, +X)
};

// private: map of direction characters to direction
const _directions = {94: 1, 118: 2, 60: 3, 62: 4, 88: undefined};

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

    // private: the scaffold grid
    this._grid = new PuzzleGrid({
      0: {name: 'space', render: '.'},
      1: {name: 'scaffold', render: '#'},
      2: {name: 'intersection', render: 'O'},
    });
    // private: [Y, X] position of vacuum robot
    this._position = undefined;
    // private: direction of vacuum robot (1=up 2=down 3=left 4=right)
    this._direction = undefined;
    /**
     * the amount of dust cleaned by the vacuum robot
     * @member {number}
     */
    this.dust = 0;
    // private: provide continuous video feed?
    this._continuousVideo = false;
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
    let state = 'video', fno = 0, promptStr = '', gPath, gFunctions;
    let y = 0, x = 0;
    // IN sends the next ASCII character
    const getValue = (() => {
      if (state === 'prompt') {
        let m;
        if (promptStr === 'Main:\n') {
          state = 'function';
          fno = 0;
          promptStr = '';
        } else if ((m = promptStr.match(/^Function (\w):\n$/))) {
          state = 'function';
          fno = m[1].charCodeAt(0) - 64;
          promptStr = '';
        } else if (promptStr === 'Continuous video feed?\n') {
          state = 'feed';
          promptStr = this._continuousVideo ? 'y' : 'n';
        } else {
          throw new Error(`getValue: unhandled promptStr [${promptStr}]`);
        }
      }
      if (state === 'function') {
        if (gFunctions[fno].length === 0) {
          state = 'prompt';
          return 10;
        }
        const v = gFunctions[fno].slice(0, 1).charCodeAt(0);
        gFunctions[fno] = gFunctions[fno].slice(1, gFunctions[fno].length);
        //console.debug(`send char ${v} [${String.fromCharCode(v)}] for function ${fno}, remainder=[${gFunctions[fno]}]`);
        return v;
      } else if (state === 'feed') {
        if (promptStr.length === 1) {
          const v = promptStr.charCodeAt(0);  // 'n' or 'y'
          promptStr = '';
          return v;
        } else {
          state = 'video';
          y = 0;
          x = 0;
          this._position = undefined;
          this._direction = undefined;
          return 10;
        }
      } else if (state === 'done') {
        return undefined;
      } else {
        throw new Error(`getValue unhandled state ${state}`);
      }
    });
    // OUT gives us the next ASCII character
    const storeValue = ((v) => {
      // "Once it finishes the programmed set of movements, [...] the
      // cleaning robot will [...] report the amount of space dust it
      // collected as a large, non-ASCII value in a single output
      // instruction."
      if (v > 127) {
        this.dust = v;
        state = 'done';
        return;
      }
      if (state === 'video') {
        switch (v) {
        case 10:  // \n (go to next line)
          if ((x === 0) && (y > 0)) {
            // extra \n at end signals video frame is done
            if (this._continuousVideo) {
              // TODO this isn't very useful, since dump() doesn't show the
              //      robot on the grid
              this._grid.dump();
              console.log(`robot position: [${this._position}] direction: ${this._direction}`);
              console.log('');
            }
            if (!gPath) {
              gPath = pathAnalyzer.path(this._grid, this._position, this._direction);
              gFunctions = pathAnalyzer.functions(gPath);
              state = 'prompt';
            } else {
              state = this._continuousVideo ? 'video' : 'prompt';
            }
            promptStr = '';
            y = 0;
          } else if (x > 0) {
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
        case 94:  // ^ = robot faces up
        case 118: // v = robot faces down
        case 60:  // < = robot faces left
        case 62:  // > = robot faces right
        case 88:  // X = robot is tumbling through space
          this._position = [y, x];
          this._direction = _directions[v];
          this._grid.set([y, x++], (v === 88) ? 0 : 1);
          //console.debug(`got ${v} [${String.fromCharCode(v)}] robot pos: ${this._position} dir: ${this._direction}`);
          break;
        /* istanbul ignore next */
        default:
          throw new Error(`got unknown video character ${v} [${String.fromCharCode(v)}]`);
        }
      } else if (state === 'prompt') {
        if (v < 128) {
          promptStr += String.fromCharCode(v);
        }
      } else if (state === 'done') {
        return;
      } else {
        throw new Error(`got character ${v} while in unsupported state ${state}`);
      }
    });
    intcode.run(this._program, false, getValue, storeValue);
    if (mode === 1) {
      this._findIntersections();
    }
  }
  // private: find scaffold intersections, setting them on the puzzle grid
  _findIntersections()
  {
    // FIXME this should be a PuzzleGrid method "find positions with contents X"
    const scaffolds = Array.from(this._grid._grid.keys())
      .filter((k) => this._grid._grid.get(k) === 1)
      .map((k) => k.split(',').map((p) => Number(p)));
    const intersections = scaffolds.filter((pos) => {
      // is there a scaffold in every direction from this position?
      return Object.keys(_offsets).every((dir) => {
        const dirPos = [pos[0] + _offsets[dir][0], pos[1] + _offsets[dir][1]];
        return this._grid.get(dirPos) === 1;
      });
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
    // FIXME this should be a PuzzleGrid method "find positions with contents X"
    return Array.from(this._grid._grid.keys())
      .filter((k) => this._grid._grid.get(k) === 2)
      .map((k) => k.split(',').map((p) => Number(p)));
  }
}
module.exports = Scaffold;
