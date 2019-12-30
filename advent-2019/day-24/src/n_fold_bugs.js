'use strict';
/** @module */

/*
 * "Call this level 0; the grid within this one is level 1, and the grid
 * that contains this one is level -1."
 *
 * terminology:
 * - we'll call "above" the -L direction (the level "above" us contains us),
 *   and "below" the +L direction (the level "below" us is contained by us)
 * - a "grid" or "state" is the "simple node" at a given level: it's just a
 *   5x5 bit field [the center [2,2] square on this grid is considered
 *   "undefined" since it holds the level below it]
 * - a "square" or "tile" is one position in a "grid" or "state" (simple
 *   node)
 * - a "level" is the "complex node": it's an object that has a grid (state)
 *   representing this level, a pointer to the level above it, and a pointer
 *   to the level below it
 */

//      |     |         |     |     
//   1  |  2  |    3    |  4  |  5  
//      |     |         |     |     
// -----+-----+---------+-----+-----
//      |     |         |     |     
//   6  |  7  |    8    |  9  |  10 
//      |     |         |     |     
// -----+-----+---------+-----+-----
//      |     |A|B|C|D|E|     |     
//      |     |-+-+-+-+-|     |     
//      |     |F|G|H|I|J|     |     
//      |     |-+-+-+-+-|     |     
//  11  | 12  |K|L|?|N|O|  14 |  15 
//      |     |-+-+-+-+-|     |     
//      |     |P|Q|R|S|T|     |     
//      |     |-+-+-+-+-|     |     
//      |     |U|V|W|X|Y|     |     
// -----+-----+---------+-----+-----
//      |     |         |     |     
//  16  | 17  |    18   |  19 |  20 
//      |     |         |     |     
// -----+-----+---------+-----+-----
//      |     |         |     |     
//  21  | 22  |    23   |  24 |  25 
//      |     |         |     |     
//
// Tile 19 has four adjacent tiles: 14, 18, 20, and 24.
// Tile G has four adjacent tiles: B, F, H, and L.
// Tile D has four adjacent tiles: 8, C, E, and I.
// Tile E has four adjacent tiles: 8, D, 14, and J.
//
// Tile 14 has eight adjacent tiles: 9, E, J, O, T, Y, 15, and 19.
// Tile N has eight adjacent tiles: I, O, S, and five tiles within the sub-grid marked ?.

/**
 * Parse a grid state.
 *
 * @param {Array} lines - lines on the grid
 *
 * @return {number}
 *   Returns the parsed state.
 */
exports.parseOne = (lines) => {
  let state = 0b0;
  for (let y = 0, bit = 0b1; y < 5; y++) {
    for (let x = 0; x < 5; x++, bit *= 2) {
      const pixel = (lines[y][x] === '#') ? 0b1 : ((lines[y][x] === '.') ? 0b0 : ((lines[y][x] === '?') ? 0b0 : NaN));
      if (isNaN(pixel)) {  // invalid character
        return NaN;
      }
      state |= bit * pixel;
    }
  }
  return state;
};
/**
 * Parse a multi-level state.
 *
 * @param {Array} levelLines - list of levels to parse (each one is an Array
 *   of lines (strings), suitable to send to `parse()`)
 * @param {number} start - level number (depth) of first entry in `levels`
 *   (successive level numbers will be +1 (lower depths) from the previous
 *   level)
 *
 * @return {object}
 *   Returns the parsed multi-level structure, starting at level (depth) 0.
 */
exports.parseMultiLevel = (levelLines, start) => {
  let level = {};
  let level0 = level;  // in case array isn't long enough
  let nLevel = start;
  levelLines.forEach((lines) => {
    if (nLevel > start) {
      level.below = {};
      level.below.above = level;
      if (level.above) {
        level.above.below = level;
      }
      level = level.below;
    }
    if (nLevel === 0) {
      level0 = level;
    }
    level.state = module.exports.parseOne(lines);
    level.number = nLevel++;
  });
  return level0;
};
// private: is this the center square of the grid?
const _isCenter = (pos) => {
  return (pos[0] === 2) && (pos[1] === 2);
};
// private: is this position outside the grid?
const _isOutside = (pos) => {
  return (pos[0] < 0) || (pos[1] < 0) || (pos[0] > 4) || (pos[1] > 4);
};
// private: [Y, X] indexer
const _posIndex = (pos) => {
  return pos[0] * 5 + pos[1];
};
// private: is there a bug at the given grid position?
const _isBugAt = (state, pos) => {
  /* istanbul ignore if */
  if (_isOutside(pos)) {
    throw new Error(`isBugAt called for pos=${pos} outside grid`);
  }
  const bit = Math.pow(2, _posIndex(pos));
  return (state & bit) ? true : false;
};
/**
 * Format a grid state.
 *
 * @param {number} state - the grid state
 *
 * @return {Array}
 *   Returns a list of grid lines (strings).
 */
exports.formatOne = (state) => {
  const lines = [];
  for (let y = 0, s = '', bit = 0b1; y < 5; y++, s = '') {
    for (let x = 0; x < 5; x++, bit *= 2) {
      const b = _isCenter([y, x]) ? undefined : _isBugAt(state, [y, x]);
      s += ((b === undefined) ? '?' : (b ? '#' : '.'));
    }
    lines.push(s);
  }
  return lines;
};
/* istanbul ignore next */
/**
 * Format a multi-level state.
 *
 * @param {object} level - the origin level
 *
 * @return {Array}
 *   Returns a list of strings.
 */
exports.formatMultiLevel = (level) => {
  const lines = [];
  while (level.above) {
    level = level.above;
  }
  while (level) {
    lines.push(`Depth ${level.number}:`);
    const gridLines = module.exports.formatOne(level.state);
    gridLines.forEach((line) => lines.push(line));
    lines.push('');
    level = level.below;
  }
  return lines;
};
/**
 * Count bugs along a grid edge.
 *
 * If:
 * - `y > 0` count along the top edge
 * - `y < 0` count along the bottom edge
 * - `x > 0` count along the left edge
 * - `x < 0` count along the right edge
 *
 * @param {number} state - the grid state
 * @param {number} y - the Y value
 * @param {number} x - the X value
 *
 * @return {number}
 *   Returns the number of bugs on the given edge.
 */
exports.edgeCount = (state, y, x) => {
  if ((x === 0) && (y === 0)) {
    throw new Error('only one of [Y, X] can be 0');
  } else if ((x !== 0) && (y !== 0)) {
    throw new Error('only one of [Y, X] can be non-0');
  }
  // TODO the 4 reduces are almost the same; move to subfunction
  if (y > 0) {
    //console.debug(`state=${state}, grid:`);
    //module.exports.formatOne(state).forEach((line) => console.debug('        '+line));
    //console.debug('keys:');
    //console.dir([...Array(5).keys()]);
    //console.debug('map:');
    //console.dir([...Array(5).keys()].map((x) => _isBugAt(state, [0, x])));
    return [...Array(5).keys()].map((x) => _isBugAt(state, [0, x]))
      .reduce((sum, b) => sum + b, 0);
  } else if (y < 0) {
    return [...Array(5).keys()].map((x) => _isBugAt(state, [4, x]))
      .reduce((sum, b) => sum + b, 0);
  } else if (x > 0) {
    return [...Array(5).keys()].map((y) => _isBugAt(state, [y, 0]))
      .reduce((sum, b) => sum + b, 0);
  } else {  // x < 0
    return [...Array(5).keys()].map((y) => _isBugAt(state, [y, 4]))
      .reduce((sum, b) => sum + b, 0);
  }
};
/**
 * Count adjacent bugs at a position on a level.
 *
 * This function takes into account that adjacency can involve positions on
 * the level above and/or below this level.
 *
 * @param {object} level - the level
 * @param {Array} pos - the [Y, X] position
 *
 * @return {number}
 *   Returns the number of bugs adjacent to the given position.
 */
exports.countOfAdjacentAt = (level, pos) => {
  // the center square is the level below us; we can't count-adjacent from
  // that position:
  if (_isCenter(pos)) {
    return undefined;
  }
  const dirs = [
    [-1, 0],  // up
    [1, 0],   // down
    [0, -1],  // left
    [0, 1],   // right
  ];
  //console.debug(`state=${level.state}, grid:`);
  //module.exports.formatOne(level.state).forEach((line) => console.debug('        '+line));
  //console.debug('level=');
  //console.dir(level);
  return dirs.map((dir) => {
    const y = pos[0] + dir[0];
    const x = pos[1] + dir[1];
    if (_isCenter([y, x])) {
      // the square at `pos` has 5 neighbors in this direction, namely,
      // the 5 squares of the adjacent edge of the grid below us:
      //console.debug(`for pos=${pos} checking dir=${dir} below adjPos=${[y, x]} (5-square edge)`);
      return level.below ? module.exports.edgeCount(level.below.state, dir[0], dir[1]) : 0;
    }
    if (_isOutside([y, x])) {
      // the neighbor in this direction is on the grid above us;
      // one of the four squares cardinally outward from its center:
      const ay = 2 + dir[0];
      const ax = 2 + dir[1];
      //console.debug(`for pos=${pos} checking dir=${dir} above adjPos=${[ay, ax]}`);
      return level.above ? (_isBugAt(level.above.state, [ay, ax]) ? 1 : 0) : 0;
    }
    // otherwise, simple count from our grid:
    //console.debug(`for pos=${pos} checking dir=${dir} adjPos=${[y, x]}`);
    return _isBugAt(level.state, [y, x]) ? 1 : 0;
  }).reduce((sum, b) => sum + b, 0);
};
/**
 * Determine next event at a position on a level.
 *
 * @param {object} level - the level
 * @param {Array} pos - the [Y, X] position
 *
 * @return {string}
 *   Returns one of `death`, `spawn`, `stasis`.
 */
exports.eventAt = (level, pos) => {
  // the center square is the level below us; we can't find-event for that
  // position:
  if (_isCenter(pos)) {
    return undefined;
  }
  const isBug = _isBugAt(level.state, pos);
  const count = module.exports.countOfAdjacentAt(level, pos);
  //console.debug(`pos ${pos} bug? ${isBug} count ${count}`);
  /*
   * "A bug dies (becoming an empty space) unless there is exactly one bug
   *   adjacent to it."
   * "An empty space becomes infested with a bug if exactly one or two bugs
   *   are adjacent to it."
   * "Otherwise, a bug or empty space remains the same."
   */
  switch (count) {
  case 0:
    return isBug ? 'death'  : 'stasis';
  case 1:
    return isBug ? 'stasis' : 'spawn';
  case 2:
    return isBug ? 'death'  : 'spawn';
  default:  // 3, 4
    return isBug ? 'death'  : 'stasis';
  }
};
const _hasCenterAdjacentBugs = (state) => {
  return (state & 0b0000000100010100010000000) !== 0b0;
};
const _hasEdgeBugs = (state) => {
  return (state & 0b1111110001100011000111111) !== 0b0;
};
const _addAboveAndBelow = (level) => {
  if (!level.above && _hasEdgeBugs(level.state)) {
    level.above = {state: 0b0, below: level};
    level.above.number = level.number - 1;
  }
  if (!level.below && _hasCenterAdjacentBugs(level.state)) {
    level.below = {state: 0b0, above: level};
    level.below.number = level.number + 1;
  }
};
/**
 * Generate next state from the current state of one level.
 *
 * @param {object} level - the level
 *
 * @return {number}
 *   Returns the next state of the given level.
 */
exports.generateOne = (level) => {
  //module.exports.formatOne(level.state).forEach((line) => console.debug(' start-> '+line));
  // add above/below levels, if they'll be needed:
  _addAboveAndBelow(level);
  // compute new state:
  let state = 0b0;
  for (let y = 0, bit = 0b1; y < 5; y++) {
    for (let x = 0; x < 5; x++, bit *= 2) {
      if (_isCenter([y, x])) {
        continue;
      }
      const event = module.exports.eventAt(level, [y, x]);
      //console.debug(`pos ${[y, x]} event ${event}`);
      switch (event) {
      case 'death':
        state &= ~bit;
        break;
      case 'spawn':
        state |= bit;
        break;
      case 'stasis':
        state |= (level.state & bit);
        break;
      }
    }
  }
  //module.exports.formatOne(state).forEach((line) => console.debug('   end-> '+line));
  return state;
};
/**
 * Generate next state from current state, on all levels.
 *
 * @param {object} level - the origin level
 */
exports.generateMultiLevel = (level) => {
  /*
   * first generate the next state for all levels; remember: "This process
   * happens in every location simultaneously; that is, within the same
   * minute, the number of adjacent bugs is counted for every tile first,
   * and then the tiles are updated."
   */
  const startLevel = level;
  // note this needs to happen from the initial level outward in both
  // directions, so newly-added levels will be generated too:
  level.nextState = module.exports.generateOne(level);
  while (level.above) {
    level = level.above;
    level.nextState = module.exports.generateOne(level);
  }
  level = startLevel;
  while (level.below) {
    level = level.below;
    level.nextState = module.exports.generateOne(level);
  }
  /*
   * then update all the states at the end
   */
  level = startLevel;
  while (level.above) {
    level = level.above;
  }
  while (level) {
    level.state = level.nextState;
    delete level.nextState;
    level = level.below;
  }
};
/**
 * Iterate generations.
 *
 * @param {object} level - the origin level
 * @param {number} count - the number of iterations
 */
exports.iterateMultiLevel = (level, count) => {
  while (count-- > 0) {
    module.exports.generateMultiLevel(level);
  }
};
/**
 * Count bugs on a grid.
 *
 * @param {number} state - the grid state
 *
 * @return {number}
 *   Returns the number of bugs on the grid.
 */
exports.countOne = (state) => {
  let count = 0;
  for (let y = 0, bit = 0b1; y < 5; y++) {
    for (let x = 0; x < 5; x++, bit *= 2) {
      if (_isBugAt(state, [y, x])) {
        count++;
      }
    }
  }
  return count;
};
/**
 * Count the bugs on all levels.
 *
 * @param {object} level - the origin level
 *
 * @return {number}
 *   Returns the number of bugs on all levels.
 */
exports.countMultiLevel = (level) => {
  while (level.above) {
    level = level.above;
  }
  let count = 0;
  while (level) {
    count += module.exports.countOne(level.state);
    level = level.below;
  }
  return count;
};
