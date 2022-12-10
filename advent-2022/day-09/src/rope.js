'use strict';
/** @module rope */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Array}
 *   Returns a list of motions.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `R 4`)
 *
 * @return {Array}
 *   Returns a motion.
 */
exports.parseLine = (line) => {
  const tokens = line.split(/\s+/);
  return [tokens[0], parseInt(tokens[1])];
};

const posKey = ((coord) => '' + coord.y + ',' + coord.x);

exports.touching = ((a, b) => {
  const dy = Math.abs(a.y - b.y);
  const dx = Math.abs(a.x - b.x);
  return (dy <= 1) && (dx <= 1);
});
const moveDelta = {
  R: {y: 0, x: 1},
  L: {y: 0, x: -1},
  D: {y: 1, x: 0},
  U: {y: -1, x: 0},
};
/**
 * Move head knot one unit in the given direction.
 *
 * (The `pos` argument is directly updated; the function doesn't
 * return anything.)
 *
 * @param pos {Object} - current position of knot
 * @param dir {string} - direction to move (`R` `L` `D` `U`)
 */
exports.move = ((pos, dir) => {
  if (!moveDelta[dir]) {
    throw new SyntaxError(`unknown direction '${dir}'`);
  }
  pos.y += moveDelta[dir].y;
  pos.x += moveDelta[dir].x;
});

exports.moveTail = ((tail, head) => {
  const dy = head.y - tail.y;
  const dx = head.x - tail.x;
  // "If the head is ever two steps directly up, down, left, or right
  // from the tail, the tail must also move one step in that direction
  // so it remains close enough"
  if ((Math.abs(dx) === 2) && (dy === 0)) {
    tail.x += (dx / 2);
    return;
  } else if ((Math.abs(dy) === 2) && (dx === 0)) {
    tail.y += (dy / 2);
    return;
  }
  // "Otherwise, if the head and tail aren't touching and aren't in
  // the same row or column, the tail always moves one step diagonally
  // to keep up"
  if (module.exports.touching(tail, head)) {
    return;
  }
  if (Math.abs(dx) > Math.abs(dy)) {
    tail.x += (dx / 2);
    tail.y += dy;
  } else if ((Math.abs(dx) === 2) && (Math.abs(dy) === 2)) {
    tail.x += (dx / 2);
    tail.y += (dy / 2);
  } else {
    tail.x += dx;
    tail.y += (dy / 2);
  }
});

exports.followMotions = ((motions) => {
  const head = {y: 0, x: 0};
  const tail = {y: 0, x: 0};
  const visited = {};
  visited[posKey(tail)] = true;
  motions.forEach((motion) => {
    for (let i = 0; i < motion[1]; i++) {
      module.exports.move(head, motion[0]);
      module.exports.moveTail(tail, head);
      visited[posKey(tail)] = true;
    }
  });
  //console.dir(visited);
  return Object.keys(visited).length;
});

const dumpRope = ((rope, grid) => {
  for (let y = grid.y0; y <= grid.y1; y++) {
    let line = '';
    for (let x = grid.x0; x <= grid.x1; x++) {
      for (let i = 0; i < 10; i++) {
        if ((rope[i].y === y) && (rope[i].x === x)) {
          const ch = (i === 0) ? 'H' : ('' + i);
          line += ch;
          break;
        } else if (i === 9) {
          line += '.';
        }
      }
    }
    console.log(line);
  }
  console.log('');
});

exports.followMotions10 = ((motions, dumpGrid) => {
  const rope = [
    {y: 0, x: 0}, {y: 0, x: 0}, {y: 0, x: 0},
    {y: 0, x: 0}, {y: 0, x: 0}, {y: 0, x: 0},
    {y: 0, x: 0}, {y: 0, x: 0}, {y: 0, x: 0},
    {y: 0, x: 0},
  ];
  const visited = {};
  visited[posKey(rope[9])] = true;
  motions.forEach((motion) => {
    if (dumpGrid) {
      console.log(`== ${motion[0]} ${motion[1]} ==`);
      console.log('');
    }
    for (let i = 0; i < motion[1]; i++) {
      module.exports.move(rope[0], motion[0]);
      for (let k = 1; k < 10; k++) {
        module.exports.moveTail(rope[k], rope[k-1]);
      }
      visited[posKey(rope[9])] = true;
      if (dumpGrid && (dumpGrid.all === true)) {
        dumpRope(rope, dumpGrid);
      }
    }
    if (dumpGrid && (dumpGrid.all === false)) {
      dumpRope(rope, dumpGrid);
    }
  });
  //console.dir(visited);
  return Object.keys(visited).length;
});
