'use strict';
const Board = require('../src/board');
const floyd = require('../../../advent-2019/shared/src/floyd');

class Tetris
{
  /**
   * Parse the puzzle input.
   *
   * @param {string} input - lines of puzzle input separated by `\n`
   *
   * @return {Array.Object}
   *   Returns a list of [TBP].
   */
  constructor(input, debug)
  {
    this._jets = input.trim().split('');
    // element 0 of each shape is the lowest row
    // TODO might not need the trailing 0s
    this._shapes = [
      // ####
      [0b1111, 0b0000, 0b0000, 0b0000],
      // .#.
      // ###
      // .#.
      [0b0100, 0b1110, 0b0100, 0b0000],
      // ..#
      // ..#
      // ###
      [0b1110, 0b0010, 0b0010, 0b0000],
      // #
      // #
      // #
      // #
      [0b1000, 0b1000, 0b1000, 0b1000],
      // ##
      // ##
      [0b1100, 0b1100, 0b0000, 0b0000],
    ];
    this._debug = debug;
    this._initialize();
  }
  _initialize()
  {
    this._currentJet = 0;
    this._currentShape = 0;
    this._board = new Board(this._debug);
  }
  nextJet()
  {
    const jet = this._jets[this._currentJet];
    this._currentJet += 1;
    this._currentJet %= this._jets.length;
    return jet;
  }
  nextShape()
  {
    const shape = this._shapes[this._currentShape];
    this._currentShape += 1;
    this._currentShape %= this._shapes.length;
    // TODO do the left-shift here
    return [...shape];  // copy
  }
  boardHeight()
  {
    return this._board.height();
  }
  blow(mergeRow, overlap, shape)
  {
    let newShape;
    let consoleDir;
    switch (this.nextJet()) {
    case '<':
      consoleDir = 'left';
      if (shape.find((line) => line & 0b1000000) !== undefined) {
        // left wall blocks movement
        if (this._debug) {
          console.log(`Jet of gas pushes rock ${consoleDir}, but nothing happens: [W]`);
        }
        return shape;
      }
      newShape = shape.map((b) => b << 1);
      break;
    case '>':
      consoleDir = 'right';
      if (shape.find((line) => line & 0b0000001) !== undefined) {
        // right wall blocks movement
        if (this._debug) {
          console.log(`Jet of gas pushes rock ${consoleDir}, but nothing happens: [W]`);
        }
        return shape;
      }
      newShape = shape.map((b) => b >> 1);
      break;
    default:
      throw new SyntaxError('unknown jet');
    }
    if (this._board.collision(mergeRow, overlap, newShape, true)) {
      // tower blocks movement
      if (this._debug) {
        console.log(`Jet of gas pushes rock ${consoleDir}, but nothing happens: [T]`);
      }
      return shape;
    }
    if (this._debug) {
      console.log(`Jet of gas pushes rock ${consoleDir}:`);
    }
    return newShape;
  }
  dropNextShape()
  {
    this._board.makeSpace();
    let shape = this.nextShape().map((b) => b << 1);
    if (this._debug) {
      console.log('The next rock begins falling:');
      this._board.drawShape(shape, '@');
      this._board.drawBoard();
    }
    let mergeRow = this._board.height();
    let overlap = 0;
    for (;;) {
      shape = this.blow(mergeRow, overlap, shape);
      if (this._debug) {
        this._board.drawShape(shape, '@');
        this._board.drawBoard();
      }
      if (this._board.shrink()) {
        // mergeRow is just empty space; shape can continue falling
        if (this._debug) {
          console.log('Rock falls 1 unit:');
          this._board.drawShape(shape, '@');
          this._board.drawBoard();
        }
        mergeRow--;
      } else if (this._board.collision(mergeRow, overlap + 1, shape)) {
        // shape hit top of tower and can't fall any further
        break;
      } else if (mergeRow <= 0) {
        // shape hit floor and can't fall any further
        break;
      } else {
        // shape can fall, overlapping with top of tower
        mergeRow--;
        overlap++;
        if (this._debug) {
          console.log('Rock falls 1 unit: [O]');
          // TODO sadly the draw functions can't handle this yet
          this._board.drawShape(shape, '@');
          for (let r = 0; r < overlap; r++) {
            console.log(' ~~~~~~~ ');
          }
          this._board.drawBoard();
        }
      }
    }
    if (this._debug) {
      console.log('Rock falls 1 unit, causing it to come to rest:');
    }
    this._board.addShape(mergeRow, overlap, shape);
    if (this._debug) {
      this._board.drawBoard();
    }
  }
  dropShapes(n)
  {
    for (let i = 0; i < n; i++) {
      this.dropNextShape();
    }
  }
  dropShapesCyclical(n)
  {
    /*
     * Ensure we're using BigInt.
     */
    const argType = Object.prototype.toString.call(n);
    if (argType !== '[object BigInt]') {
      throw new TypeError('argument must be BigInt');
    }
    /*
     * Fill board enough for Floyd to find a cycle
     */
    const stateKey = ((state) => state.sum << state.afterShape);
    const states = {};
    const initialState = (() => ({sum: 0, afterShape: 4}));
    for (let i = 0, state = initialState(); i < 100000; i++) {
      this.dropNextShape();
      const newState = this._board.state();
      if (newState.sum === state.sum) {
        throw new SyntaxError(`populate i=${i} consecutive sums match ${state.sum}`);
      } else if (newState.afterShape !== ((state.afterShape + 1) % 5)) {
        throw new SyntaxError(`populate i=${i} shape=${state.afterShape} newShape=${newState.afterShape}`);
      }
      states[stateKey(state)] = newState;
      state = newState;
    }
    const nFirstShapes = this._board.nShapesAdded();
    if (this._debug) {
      console.debug(`nFirstShapes=${nFirstShapes} states.length=${Object.keys(states).length}`);
    }
    /*
     * Run Floyd cycle detection.
     */
    // f: function which transforms the current state to the
    //    next state in the sequence [`f(x0)` returns `x1`]
    const f = ((x) => {
      if (!x) {
        throw new SyntaxError(`board exhausted; states.length=${Object.keys(states).length}`);
      }
      return states[stateKey(x)];
    });
    // eq: function which detects equality of two states
    //     [`eq(a, b)` returns `true` if states are equal]
    const eq = ((a, b) => {
      return (a.sum === b.sum) && (a.afterShape === b.afterShape);
    });
    // 3rd param: initial state (of the type `f(x)` expects)
    // return:    [cycle-length, first-occurrence]
    const lmu = floyd.run(f, eq, initialState());
    const cycleLength = BigInt(lmu[0]);
    const firstOccurrence = BigInt(lmu[1]);
    /*
     * Do the math!
     */
    this._initialize();
    // drop the initial shapes before the first cycle begins, and
    // record that height:
    for (let i = 0n; i < firstOccurrence; i++, n--) {
      this.dropNextShape();
    }
    const firstHeight = BigInt(this.boardHeight());
    // drop one cycle's worth of shapes to determine cycle height:
    for (let i = 0n; i < cycleLength; i++, n--) {
      this.dropNextShape();
    }
    const cycleHeight = BigInt(this.boardHeight()) - firstHeight;
    // figure out how many cycles we're skipping, and their height:
    const skipCycles = n / cycleLength;
    const skipHeight = skipCycles * cycleHeight;
    const skipRem = n % cycleLength;
    // drop the last fractional cycle's shapes:
    for (let i = 0n; i < skipRem; i++, n--) {
      this.dropNextShape();
    }
    const remHeight = BigInt(this.boardHeight()) - firstHeight - cycleHeight;
    return firstHeight + cycleHeight + skipHeight + remHeight;
  }
}
module.exports = Tetris;
