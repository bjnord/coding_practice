'use strict';

class Robot
{
  /**
   * Build a new "emergency hull painting robot" from an input string.
   *
   * @param {string} input - the input string, an Intcode program (which
   * "will serve as the brain of the robot")
   *
   * @return {Robot}
   *   Returns a new Robot class object.
   */
  constructor(input)
  {
    // private: our Intcode program
    this.program = input.trim().split(/,/).map((str) => Number(str));
    // private: hull panel colors (key: position, value: 0=black 1=white)
    this.grid = new Map();
    // private: [y, x] position of robot
    this.position = [0, 0];
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
   *
   * @return {Array}
   *   Returns a list of the [y, x] positions of asteroids visible from the
   *   given origin (excluding the origin asteroid itself).
   */
  move(turn)
  {
    this.direction = (turn ? (this.direction + 1) : (this.direction + 3)) % 4;
    this.position[0] += [-1, 0, 1, 0][this.direction];  // dY
    this.position[1] += [0, 1, 0, -1][this.direction];  // dX
    this.justPainted = false;
  }
  /*
   * Run the paint controlling Intcode program until it halts.
   *
  run()
  {
    // method run() - go to it
    //   arranges in callback to send currentColor()
    //   arranges out callback
    //     - if justPainted, call move(turn) with output value
    //     - otherwise, call paint(color) with output value
    // TODO
  }
   */
  // private: map key for a given [y, x] location
  static _mapKey(position)
  {
    return `${position[0]},${position[1]}`;
  }
}
module.exports = Robot;
