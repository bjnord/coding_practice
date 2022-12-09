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

exports.move = ((pos, dir) => {
  switch (dir) {
    case 'R':
      pos.x += 1;
      break;
    case 'L':
      pos.x -= 1;
      break;
    case 'U':
      pos.y += 1;
      break;
    case 'D':
      pos.y -= 1;
      break;
    default:
      throw new SyntaxError(`unknown direction '${dir}'`);
  }
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
