'use strict';
const math = require('../../shared/src/math');
const _debug = false;
/** @module plant */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of [TBP].
 */
exports.parse = (input) => {
  const rows = input.trim().split(/\n/)
    .map((line) => module.exports.parseLine(line));
  const elves = [];
  let y = 0;
  for (const row of rows) {
    for (let x = 0; x < row.length; x++) {
      if (row[x]) {
        elves.push({y, x});
      }
    }
    y--;
  }
  return elves;
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `.##..`)
 *
 * @return {Array.boolean}
 *   Returns a list of pixels.
 */
exports.parseLine = (line) => {
  return line.split('').map((ch) => ch === '#');
};
/*
 * Turn y,x `Object` position into `string` suitable for a map key.
 */
const posKey = ((pos) => '' + pos.y + ',' + pos.x);

exports.makeMap = ((elves) => {
  return elves.reduce((map, pos) => {
    map[posKey(pos)] = pos;
    return map;
  }, {});
});

exports.neighborElves = ((pos, map) => {
  const neighbors = [];
  for (let y = 1; y >= -1; y--) {
    for (let x = -1; x <= 1; x++) {
      if ((y === 0) && (x === 0)) {
        continue;
      }
      const nPos = {y: pos.y + y, x: pos.x + x};
      const neighbor = map[posKey(nPos)];
      if (neighbor) {
        neighbors.push(neighbor);
      }
    }
  }
  return neighbors;
});

const checkDirections = ((elf, neighbors, round) => {
  if (_debug) {
    console.debug(`=== checking ${posKey(elf)} round ${round}`);
    console.dir(neighbors);
    console.debug('');
  }
  const dirs = [
    [ 1,  0],  // N
    [-1,  0],  // S
    [ 0, -1],  // W
    [ 0,  1],  // E
  ];
  const neighborKeys = neighbors.map((neighbor) => posKey(neighbor));
  for (let dir = 0; dir < 4; dir++) {
    const roundDir = math.mod(round - 1 + dir, 4);
    let edgeClear = true;
    if (dirs[roundDir][1] === 0) {
      // check N/S (y axis)
      for (let x = -1; x <= 1; x++) {
        const nPos = {y: elf.y + dirs[roundDir][0], x: elf.x + x}
        if (neighborKeys.includes(posKey(nPos))) {
          if (_debug) {
            console.debug(`found at x=${x} nPos=${posKey(nPos)}`);
          }
          edgeClear = false;
          break;
        } else {
          if (_debug) {
            console.debug(`!found at x=${x} nPos=${posKey(nPos)}`);
          }
        }
      }
      if (edgeClear) {
        return {y: elf.y + dirs[roundDir][0], x: elf.x}
      }
    } else {
      // check E/W (x axis)
      for (let y = 1; y >= -1; y--) {
        const nPos = {y: elf.y + y, x: elf.x + dirs[roundDir][1]}
        if (neighborKeys.includes(posKey(nPos))) {
          if (_debug) {
            console.debug(`found at y=${y} nPos=${posKey(nPos)}`);
          }
          edgeClear = false;
          break;
        } else {
          if (_debug) {
            console.debug(`!found at y=${y} nPos=${posKey(nPos)}`);
          }
        }
      }
      if (edgeClear) {
        return {y: elf.y, x: elf.x + dirs[roundDir][1]}
      }
    }
    if (_debug) {
      console.debug(`not found at dir=${dir} roundDir=${roundDir} dirs:`);
      console.dir(dirs[roundDir]);
    }
  }
  if (_debug) {
    console.debug('not found at all');
  }
  return undefined;
});

exports.initialState = ((elves) => {
  const mapMin = (elves.length === 5) ? {y:  0, x:  0} : {y:  2, x: -3}
  const mapMax = (elves.length === 5) ? {y: -5, x:  4} : {y: -9, x: 10}
  return {
    map: module.exports.makeMap(elves),
    round: 1,
    mapMin,
    mapMax,
  };
});

exports.doRound = ((state) => {
  /*
   * First half: Propose moves
   */
  if (_debug) {
    console.dir('--- 1st half ---');
  }
  const elves = Object.values(state.map).map((pos) => ({y: pos.y, x: pos.x}));
  const elfProposals = [];
  for (const elf of elves) {
    const neighbors = module.exports.neighborElves(elf, state.map);
    if (neighbors.length > 0) {
      const pPos = checkDirections(elf, neighbors, state.round);
      if (pPos) {
        if (_debug) {
          console.debug(`round ${state.round}: elf at ${posKey(elf)} proposes move to ${posKey(pPos)}`);
        }
        elfProposals.push(pPos);
      } else {
        if (_debug) {
          console.debug(`round ${state.round}: elf at ${posKey(elf)} does nothing (no clear edges)`);
        }
        elfProposals.push(undefined);
      }
    } else {
      if (_debug) {
        console.debug(`round ${state.round}: elf at ${posKey(elf)} does nothing (no neighbors)`);
      }
      elfProposals.push(undefined);
    }
  }
  if (elves.length !== elfProposals.length) {
    throw new SyntaxError('mismatched arrays');
  }
  // elves and elfProposals are now parallel arrays
  const nProposals = {};
  for (const proposal of elfProposals) {
    if (proposal === undefined) {
      continue;
    }
    const k = posKey(proposal);
    if (nProposals[k] === undefined) {
      nProposals[k] = 1;
    } else {
      nProposals[k]++;
    }
  }
  if (_debug) {
    console.debug('nProposals:');
    console.dir(nProposals);
  }
  /*
   * Second half: Movement
   */
  if (_debug) {
    console.dir('--- 2nd half ---');
    console.dir(state.map);
  }
  state.anyElfMoved = false;
  for (let i = 0; i < elves.length; i++) {
    const pos = elves[i];
    const pPos = elfProposals[i];
    if (!pPos) {
      if (_debug) {
        console.debug(`round ${state.round}: elf at ${posKey(pos)} does nothing (no neighbors)`);
      }
    } else if (nProposals[posKey(pPos)] === 1) {
      if (_debug) {
        console.debug(`round ${state.round}: elf at ${posKey(pos)} moves to ${posKey(pPos)}`);
      }
      delete state.map[posKey(pos)];
      state.map[posKey(pPos)] = pPos;
      state.anyElfMoved = true;
    } else {
      if (_debug) {
        console.debug(`round ${state.round}: elf at ${posKey(pos)} does nothing (${posKey(pPos)} has ${nProposals[posKey(pPos)]} proposed)`);
      }
    }
  }
  state.round++;
});

exports.doRounds = ((state, limit) => {
  if (_debug) {
    console.log('== Initial State ==');
    module.exports.dump(state);
  }
  for (;;) {
    module.exports.doRound(state);
    if (!state.anyElfMoved) {
      return;
    }
    if (_debug) {
      console.log(`== End of Round ${state.round - 1} ==`);
      module.exports.dump(state);
    }
    if (state.round > limit) {
      return;
    }
  }
});

exports.dump = ((state) => {
  for (let y = state.mapMin.y; y >= state.mapMax.y; y--) {
    let line = '';
    for (let x = state.mapMin.x; x <= state.mapMax.x; x++) {
      line = line + (state.map[posKey({y, x})] ? '#' : '.');
    }
    console.log(line);
  }
  console.log('');
});
