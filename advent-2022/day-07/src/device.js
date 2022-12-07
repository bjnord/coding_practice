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

const calculateSize = ((subtree, path) => {
  const level = path.split('/').length - 1;
  const entries = subtree.dirs
    .map((subdir) => calculateSize(subdir, path + subdir.name + '/'))
    .flat();
  const filesSize = subtree.files
    .reduce((total, file) => total + file.size, 0);
  const dirsSize = entries
    .filter((entry) => entry.path.split('/').length === (level + 2))
    .reduce((total, entry) => total + entry.size, 0);
  entries.push({
    path,
    size: filesSize + dirsSize,
  });
  return entries;
});

exports.calculateSizes = (tree) => {
  return calculateSize(tree, '/');
};

exports.directoryToDelete = ((tree) => {
  const entries = module.exports.calculateSizes(tree);
  const rootEntry = entries.find((entry) => entry.path === '/');
  const freeSize = 70000000 - rootEntry.size;
  const addlFreeSize = 30000000 - freeSize;
  const sizableEntries = entries.filter((entry) => entry.size >= addlFreeSize)
    .sort((a, b) => Math.sign(a - b));
  return sizableEntries[0];
});
