'use strict';
/** @module device */
const parseDir = ((lines, name) => {
  const dir = {name: name, files: [], dirs: []};
  while (lines.length > 0) {
    const line = lines.shift();
    const mFile = line.match(/^(\d+)\s+(\S+)/);
    if (mFile) {
      dir.files.push({name: mFile[2], size: parseInt(mFile[1])});
      continue;
    }
    const mDir = line.match(/^\$\s+cd\s+(\S+)/);
    if (mDir) {
      if (mDir[1] === '..') {
        dir.lines = lines;
        return dir;
      }
      const childDir = parseDir(lines, mDir[1]);
      lines = childDir.lines;
      delete childDir['lines'];
      dir.dirs.push(childDir);
    }
  }
  dir.lines = [];
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
  const tree = parseDir(lines, '/');
  if (tree.lines.length > 0) {
    throw new SyntaxError('extra lines at end of input');
  }
  delete tree['lines'];
  return tree;
};

const calculateSize = ((dir) => {
  const filesSize = dir.files
    .reduce((total, file) => total + file.size, 0);
  return [{
    name: dir.name,
    size: filesSize,
  }];
});

exports.calculateSizes = (tree) => {
  return calculateSize(tree);
};
