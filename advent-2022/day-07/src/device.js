'use strict';
/** @module device */
const parseDir = ((lines, name) => {
  const dir = {name: name, files: []};
  for (let i = 0; i < lines.length; i++) {
    let m;
    m = lines[i].match(/^(\d+)\s+(\S+)/);
    if (m) {
      dir.files.push({name: m[2], size: parseInt(m[1])});
      continue;
    }
  }
  return dir;
});
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of [TBP].
 */
exports.parse = (input) => {
  const lines = input.trim().split(/\n/);
  const cdr = lines.shift();
  if (cdr !== '$ cd /') {
    throw new SyntaxError(`unexpected first line ${cdr}`);
  }
  return parseDir(lines, '/');
}
