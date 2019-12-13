'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const jupiter = require('../src/jupiter');
describe('parsing tests', () => {
  it('should return [-8, -5, -6] for <x=-6, y=-5, z=-8>', () => {
    expect(jupiter.parseLine('<x=-6, y=-5, z=-8>\n')).to.eql([-8, -5, -6]);
  });
  it('should return [-13, -3, 0] for <x=0, y=-3, z=-13>', () => {
    expect(jupiter.parseLine('<x=0, y=-3, z=-13>\n')).to.eql([-13, -3, 0]);
  });
  it('should return [-11, 10, -15] for <x=-15, y=10, z=-11>', () => {
    expect(jupiter.parseLine('<x=-15, y=10, z=-11>\n')).to.eql([-11, 10, -15]);
  });
  it('should return [3, -8, -3] for <x=-3, y=-8, z=3>', () => {
    expect(jupiter.parseLine('<x=-3, y=-8, z=3>\n')).to.eql([3, -8, -3]);
  });
  it('should parse a whole input set correctly [input.txt]', () => {
    const expected = [
      {z: [-8, 0], y: [-5, 0], x: [-6, 0]},
      {z: [-13, 0], y: [-3, 0], x: [0, 0]},
      {z: [-11, 0], y: [10, 0], x: [-15, 0]},
      {z: [3, 0], y: [-8, 0], x: [-3, 0]},
    ];
    expect(jupiter.parse('<x=-6, y=-5, z=-8>\n<x=0, y=-3, z=-13>\n<x=-15, y=10, z=-11>\n<x=-3, y=-8, z=3>\n')).to.eql(expected);
  });
});
describe('energy calculation tests', () => {
  // TODO
});
const parseExpect = (line) => {
  // pos=<x= 2, y=-8, z= 0>, vel=<x=-3, y=-2, z= 1>
  const c = line.trim().split(/=/).map((c) => parseInt(c));
  return {
    z: [c[4], c[8]],
    y: [c[3], c[7]],
    x: [c[2], c[6]],
  };
};
const compareSystems = (actual, expected) => {
  for (let i = 0; i < actual.length; i++) {
    if (actual[i].z.join(',') !== expected[i].z.join(',')) {
      console.error(`i=${i} actual.z=${actual[i].z} mismatches expected.z=${expected[i].z}`);
      return false;
    }
    if (actual[i].y.join(',') !== expected[i].y.join(',')) {
      console.error(`i=${i} actual.y=${actual[i].y} mismatches expected.y=${expected[i].y}`);
      return false;
    }
    if (actual[i].x.join(',') !== expected[i].x.join(',')) {
      console.error(`i=${i} actual.x=${actual[i].x} mismatches expected.x=${expected[i].x}`);
      return false;
    }
  }
  return true;
};
// TODO RF this works but it's a monstrosity
const simulate = (system, lines) => {
  let state = 'head', steps = 0, expected;
  while (lines.length > 0) {
    const line = lines.shift();
    if (!line.trim()) {
      //console.debug('[blank line]');
      continue;
    }
    let tok, stepTo, moon, energy;
    switch (state) {
    case 'head':
      tok = line.trim().split(/\s+/);
      switch (tok[0]) {
      case 'After':
        state = 'step';
        stepTo = Number(tok[1]);
        //console.debug(`[switch to state=${state} stepTo=${stepTo}]`);
        while (steps < stepTo) {
          jupiter.step(system);
          steps++;
        }
        expected = [];
        break;
      case 'Energy':
        state = 'energy';
        stepTo = Number(tok[2]);
        //console.debug(`[switch to state=${state} stepTo=${stepTo}]`);
        while (steps < stepTo) {
          jupiter.step(system);
          steps++;
        }
        expected = 0;
        break;
      default:
        console.error(`state=${state}: bad token [${tok[0]}] on line [${line}]`);
        return false;
      }
      break;
    case 'step':
      moon = parseExpect(line);
      //console.debug('[expect:]');
      //console.dir(moon);
      expected.push(moon);
      if (expected.length === 4) {
        if (!compareSystems(system, expected)) {
          return false;
        }
        state = 'head';
        //console.debug(`[switch to state=${state}]`);
      }
      break;
    case 'energy':
      // pot: 2 + 1 + 3 =  6;   kin: 3 + 2 + 1 = 6;   total:  6 * 6 = 36
      energy = [];
      energy[1] = Number(line.trim().split(/\s+/).pop());
      //console.debug(`[expectedEnergy=${energy[1]}]`);
      energy[0] = jupiter.totalEnergy(system[expected]);
      if (energy[0] !== energy[1]) {
        console.error(`i=${expected} actualEnergy=${energy[0]} mismatches expectedEnergy=${energy[1]}`);
        return false;
      }
      if (++expected === 4) {
        return true;
      }
      break;
    default:
      console.error(`state=${state}: bad line [${line}]`);
      return false;
    }
  }
  return true;
};
describe('movement simulation test [puzzle example #1]', () => {
  let system, lines;
  before(() => {
    lines = fs.readFileSync('input/test_1.txt', 'utf8').trim().split(/\n/);
    const moonLines = lines.slice(0, 4);
    system = jupiter.parse(moonLines.join('\n'));
    lines.splice(0, 4);
  });
  it('should simulate puzzle example #1 correctly', () => {
    expect(simulate(system, lines)).to.be.true;
  });
});
describe('movement simulation test [puzzle example #2]', () => {
  let system, lines;
  before(() => {
    lines = fs.readFileSync('input/test_2.txt', 'utf8').trim().split(/\n/);
    const moonLines = lines.slice(0, 4);
    system = jupiter.parse(moonLines.join('\n'));
    lines.splice(0, 4);
  });
  it('should simulate puzzle example #2 correctly', () => {
    expect(simulate(system, lines)).to.be.true;
  });
});
