'use strict';
const intcode = require('../../shared/src/intcode');

class Robot
{
  /**
   * Build a new "emergency hull painting robot" from an input string.
   *
   * @param {string} input - the input string, an Intcode program (which
   *   "will serve as the brain of the robot")
   * @param {number} [originColor=0] - the initial panel color at the
   *   origin position (0=black 1=white)
   *
   * @return {Robot}
   *   Returns a new Robot class object.
   */
  constructor(input, originColor = 0)
  {
    // private: our Intcode program
    this.program = input.trim().split(/,/).map((str) => Number(str));
    // private: hull panel colors (key: position, value: 0=black 1=white)
    this.grid = new Map();
    // private: [y, x] position of robot
    this.position = [0, 0];
    this.grid.set(Robot._mapKey(this.position), originColor);
    // private: direction robot is facing (0=up 1=right 2=down 3=left)
    this.direction = 0;
    // private: whether the robot just painted (and now will move)
    this.justPainted = false;
  }
  /**
   * the hull paint color under the robot's current position (0=black 1=white)
   * @member {number}
   */
  get currentColor()
  {
    // "All of the panels are currently black." so return 0=black for
    // undefined.
    return this.grid.get(Robot._mapKey(this.position)) ? 1 : 0;
  }
  /**
   * the count of hull panels that have been painted
   * @member {number}
   */
  get panelPaintedCount()
  {
    return this.grid.size;
  }
  /**
   * Paint the panel under the robot's current position.
   *
   * @param {number} color - color to paint (0=black 1=white)
   */
  paint(color)
  {
    this.grid.set(Robot._mapKey(this.position), color);
    this.justPainted = true;
  }
  /**
   * Move the robot.
   *
   * @param {number} turn - direction to turn before moving
   *   (0 = left 90 degrees, 1 = right 90 degrees)
   */
  move(turn)
  {
    this.direction = (turn ? (this.direction + 1) : (this.direction + 3)) % 4;
    this.position[0] += [-1, 0, 1, 0][this.direction];  // dY
    this.position[1] += [0, 1, 0, -1][this.direction];  // dX
    this.justPainted = false;
  }
  /* istanbul ignore next */
  /**
   * Run the paint controlling Intcode program until it halts.
   */
  run()
  {
    const getValue = (() => this.currentColor);
    const storeValue = ((v) => {
      if (this.justPainted) {
        this.move(v);
      } else {
        this.paint(v);
      }
    });
    intcode.run(this.program, false, getValue, storeValue);
  }
  // private: map key for a given [y, x] location
  static _mapKey(position)
  {
    return `${position[0]},${position[1]}`;
  }
  /* istanbul ignore next */
  /**
   * Display the painted hull panels.
   */
  dump()
  {
    const panels = Array.from(this.grid.keys()).map((k) => k.split(/,/).map((str) => Number(str)));
    const panelMin = panels.reduce((mins, p) => [Math.min(p[0], mins[0]), Math.min(p[1], mins[1])], [999999, 999999]);
    const panelMax = panels.reduce((maxes, p) => [Math.max(p[0], maxes[0]), Math.max(p[1], maxes[1])], [-999999, -999999]);
    for (let y = panelMin[0]; y <= panelMax[0]; y++) {
      for (let x = panelMin[1]; x <= panelMax[1]; x++) {
        const color = this.grid.get(Robot._mapKey([y, x])) ? 1 : 0;
        process.stdout.write((color === 1) ? '\u25a0' : ' ');
      }
      process.stdout.write('\n');
    }
  }
}
module.exports = Robot;
