'use strict';
const expect = require('chai').expect;
const Robot = require('../src/robot');
describe('robot constructor tests [black]', () => {
  let blackRobot;
  before(() => {
    blackRobot = new Robot('99');
  });
  it('should parse Intcode program correctly', () => {
    expect(blackRobot.program).to.eql([99]);
  });
  it('should set initial position correctly', () => {
    expect(blackRobot.position).to.eql([0, 0]);
  });
  it('should set initial direction correctly', () => {
    expect(blackRobot.direction).to.eql(0);
  });
  it('should set initial state correctly', () => {
    expect(blackRobot.justPainted).to.eql(false);
  });
  it('should set origin panel color correctly', () => {
    expect(blackRobot.currentColor).to.eql(0);
  });
  it('should set painted panel count correctly', () => {
    expect(blackRobot.panelPaintedCount).to.eql(1);
  });
});
describe('robot constructor tests [white]', () => {
  let whiteRobot;  // follow the white robot
  before(() => {
    whiteRobot = new Robot('99', 1);
  });
  it('should set initial position correctly', () => {
    expect(whiteRobot.position).to.eql([0, 0]);
  });
  it('should set initial direction correctly', () => {
    expect(whiteRobot.direction).to.eql(0);
  });
  it('should set initial state correctly', () => {
    expect(whiteRobot.justPainted).to.eql(false);
  });
  it('should set origin panel color correctly', () => {
    expect(whiteRobot.currentColor).to.eql(1);
  });
  it('should set painted panel count correctly', () => {
    expect(whiteRobot.panelPaintedCount).to.eql(1);
  });
});
describe('robot paint tests', () => {
  let paintRobot;
  before(() => {
    paintRobot = new Robot('99');
  });
  it("should change the paint color under the robot's current position", () => {
    let color = 1 - paintRobot.currentColor;
    paintRobot.paint(color);
    expect(paintRobot.currentColor).to.eql(color);
    color = 1 - paintRobot.currentColor;
    paintRobot.paint(color);
    expect(paintRobot.currentColor).to.eql(color);
  });
  it('should set paint flag after painting', () => {
    if (paintRobot.justPainted) {
      paintRobot.move(1);
    }
    expect(paintRobot.justPainted).to.be.false;
    paintRobot.paint(1);
    expect(paintRobot.justPainted).to.be.true;
  });
  it('should return 0=black for unpainted locations', () => {
    paintRobot.position = [-117, 234];
    expect(paintRobot.currentColor).to.eql(0);
  });
});
describe('robot move tests', () => {
  let moveRobot;
  before(() => {
    moveRobot = new Robot('99');
  });
  it('should turn right (up to right) and move', () => {
    moveRobot.position = [-2, 2];
    moveRobot.direction = 0;
    moveRobot.move(1);
    expect(moveRobot.direction).to.eql(1);
    expect(moveRobot.position).to.eql([-2, 3]);
  });
  it('should turn right (right to down) and move', () => {
    moveRobot.position = [1, 1];
    moveRobot.direction = 1;
    moveRobot.move(1);
    expect(moveRobot.direction).to.eql(2);
    expect(moveRobot.position).to.eql([2, 1]);
  });
  it('should turn right (down to left) and move', () => {
    moveRobot.position = [3, -3];
    moveRobot.direction = 2;
    moveRobot.move(1);
    expect(moveRobot.direction).to.eql(3);
    expect(moveRobot.position).to.eql([3, -4]);
  });
  it('should turn right (left to up) and move', () => {
    moveRobot.position = [-1, -1];
    moveRobot.direction = 3;
    moveRobot.move(1);
    expect(moveRobot.direction).to.eql(0);
    expect(moveRobot.position).to.eql([-2, -1]);
  });
  it('should turn left (up to left) and move', () => {
    moveRobot.position = [-2, 2];
    moveRobot.direction = 0;
    moveRobot.move(0);
    expect(moveRobot.direction).to.eql(3);
    expect(moveRobot.position).to.eql([-2, 1]);
  });
  it('should turn left (left to down) and move', () => {
    moveRobot.position = [-1, 1];
    moveRobot.direction = 3;
    moveRobot.move(0);
    expect(moveRobot.direction).to.eql(2);
    expect(moveRobot.position).to.eql([0, 1]);
  });
  it('should turn left (down to right) and move', () => {
    moveRobot.position = [3, -3];
    moveRobot.direction = 2;
    moveRobot.move(0);
    expect(moveRobot.direction).to.eql(1);
    expect(moveRobot.position).to.eql([3, -2]);
  });
  it('should turn left (right to up) and move', () => {
    moveRobot.position = [1, 1];
    moveRobot.direction = 1;
    moveRobot.move(0);
    expect(moveRobot.direction).to.eql(0);
    expect(moveRobot.position).to.eql([0, 1]);
  });
  it('should reset paint flag after moving', () => {
    if (!moveRobot.justPainted) {
      moveRobot.paint(0);
    }
    expect(moveRobot.justPainted).to.be.true;
    moveRobot.move(0);
    expect(moveRobot.justPainted).to.be.false;
  });
});
describe('robot paint count tests', () => {
  it('should only count a given panel once', () => {
    const newRobot = new Robot('99');
    expect(newRobot.panelPaintedCount).to.eql(1);
    newRobot.paint(0);
    expect(newRobot.panelPaintedCount).to.eql(1);
    newRobot.paint(1);
    expect(newRobot.panelPaintedCount).to.eql(1);
    newRobot.paint(0);
    expect(newRobot.panelPaintedCount).to.eql(1);
  });
  it('should increase count as robot paints and moves around', () => {
    const newRobot = new Robot('99');
    expect(newRobot.panelPaintedCount).to.eql(1);
    newRobot.paint(0);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(1);
    newRobot.paint(1);
    newRobot.move(1);
    expect(newRobot.panelPaintedCount).to.eql(2);
    newRobot.paint(1);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(3);
    newRobot.paint(0);
    newRobot.move(1);
    expect(newRobot.panelPaintedCount).to.eql(4);
  });
  it('should reach stasis when robot moves in a circle', () => {
    const newRobot = new Robot('99');
    // TODO this is long-winded; rewrite as forEach()
    //      taking tuples of [color, dir, expectedCount]
    expect(newRobot.panelPaintedCount).to.eql(1);
    newRobot.paint(0);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(1);
    newRobot.paint(1);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(2);
    newRobot.paint(1);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(3);
    newRobot.paint(0);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(4);
    newRobot.paint(1);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(4);
    newRobot.paint(0);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(4);
    newRobot.paint(0);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(4);
    newRobot.paint(1);
    newRobot.move(0);
    expect(newRobot.panelPaintedCount).to.eql(4);
  });
});
describe('robot run tests', () => {
  let runRobot;
  before(() => {
    runRobot = new Robot('104,1,104,1,104,1,104,1,104,1,104,1,104,1,104,1,99', 0);
  });
  it('should reflect four white painted panels (circle)', () => {
    runRobot.run();
    expect(runRobot.currentColor).to.eql(1);
    expect(runRobot.panelPaintedCount).to.eql(4);
  });
});
