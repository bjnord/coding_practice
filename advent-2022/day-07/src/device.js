'use strict';
/**
 * @module device
 *
 * @description
 *
 * The **filesystem node** data structure used in this module's functions
 * is an object with the following attributes:
 * - `name`: the basename of the directory
 * - `files`: a list of files directly contained by this directory;
 *   each file is itself an object with the following attributes:
 *   - `name`: basename of the file
 *   - `size`: the size of the file
 * - `dirs`: a list of subdirectory nodes (identical in structure to
 *   this one)
 *
 * The node with `name='/'` is the root directory. Filesystem nodes
 * can have subdirectory entries recursively, thus the root node is
 * the top of a filesystem tree.
 *
 * The **directory entry** data structure used in this module's functions
 * is an object with the following attributes:
 * - `path`: the full path to the directory, always ending in `/` (_e.g._
 *   the `b` subdirectory of the `a` top-level directory has path `/a/b/`)
 * - `size`: the total size of the directory (defined as the sum total of
 *   all files _directly or indirectly_ contained by the directory, _i.e._
 *   size of subtree, recursive)
 */
/*
 * Recursively construct filesystem tree structure from input lines.
 *
 * TODO This function is too long; given its nature (a state machine)
 *      and the nature of JavaScript (no pointers), the solution is
 *      probably to make it a class. Document it carefully for now.
 */
/* eslint-disable max-statements, complexity */
const parseDir = ((lines, name) => {
  const dir = {name: name, files: [], dirs: []};
  while (lines.length > 0) {
    const line = lines.shift();
    // FILE
    const mFile = line.match(/^(\d+)\s+(\S+)/);
    if (mFile) {
      dir.files.push({name: mFile[2], size: parseInt(mFile[1])});
      continue;
    }
    // CHANGE DIRECTORY
    const mDir = line.match(/^\$\s+cd\s+(\S+)/);
    if (mDir) {
      /*
       * Upward change-directory: Preserve remaining input lines and
       * return to our parent caller.
       */
      if (mDir[1] === '..') {
        dir.lines = lines;
        return dir;
      } 
      /*
       * Downward change-directory: Construct a child directory entry,
       * adding it to our subdirectory list and continuing with the
       * remaining input lines.
       */
      const childDir = parseDir(lines, mDir[1]);
      lines = childDir.lines;
      delete childDir['lines'];
      dir.dirs.push(childDir);
    }
    // All other input lines (_e.g._ `dir foo`) can be safely ignored.
  }
  dir.lines = [];
  return dir;
});
/* eslint-enable max-statements, complexity */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Object}
 *   Returns the root filesystem node of the tree structure.
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
/*
 * Compute the total size of all files **directly** in the given directory
 * (filesystem node).
 */
const filesSize = ((subtree) => {
  return subtree.files.reduce((total, file) => total + file.size, 0);
});
/**
 * Find all directory entries which are direct subdirectories (immediate
 * children) of the entry at `path`.
 *
 * @param entries {Array.Object} - the list of all directory entries in
 *   the filesystem
 * @param path {string} - the path of the directory entry to match against
 *
 * @return {Array.Object}
 *   Returns a list of the immediate child directory entries of `path`.
 */
exports.childEntriesOfPath = ((entries, path) => {
  const patt = new RegExp(`^${path}\\w+/$`);
  return entries.filter((entry) => entry.path.match(patt));
});
/*
 * Compute the sum of the total sizes of all **direct** subdirectories
 * of `path` (nonrecursive).
 */
const dirsSize = ((entries, path) => {
  return module.exports.childEntriesOfPath(entries, path)
    .reduce((total, entry) => total + entry.size, 0);
});
/*
 * Recursive worker for `calculateDirectorySizes()`.
 */
const calculateSize = ((subtree, path) => {
  const entries = subtree.dirs
    .map((subdir) => calculateSize(subdir, path + subdir.name + '/'))
    .flat();
  entries.push({
    path,
    size: filesSize(subtree) + dirsSize(entries, path),
  });
  return entries;
});
/**
 * Calculate the total size of each directory entry in the filesystem.
 *
 * The "total size" of a directory entry is "the sum of the sizes of the
 * files it contains, directly or indirectly" (_i.e._ all files in that
 * directory and all its subdirectories, recursively).
 *
 * @param tree {Object} - the root filesystem node of the tree structure
 *
 * @return {Array.Object}
 *   Returns a list of all directory entries, each with a computed
 *   total size.
 */
exports.calculateDirectorySizes = ((tree) => {
  return calculateSize(tree, '/');
});
/*
 * Determine how much additional free space is needed for the update.
 *
 * "The total disk space available to the filesystem is 70000000. To run
 * the update, you need unused space of at least 30000000." The root
 * directory entry has the filesystem used space (_i.e._ the total size of
 * all files on the filesystem).
 */
const addlFreeSize = ((entries) => {
  const rootEntry = entries.find((entry) => entry.path === '/');
  const currentFreeSize = 70000000 - rootEntry.size;
  return 30000000 - currentFreeSize;
});
/**
 * Find the best directory entry candidate for deletion.
 *
 * The "best" candidate is the smallest directory entry that is at least
 * as large as the additional free space needed for the update.
 *
 * @param tree {Object} - the root filesystem node of the tree structure
 *
 * @return {Object}
 *   Returns the directory entry to delete.
 */
exports.directoryToDelete = ((tree) => {
  const entries = module.exports.calculateDirectorySizes(tree);
  const sizableEntries = entries
    .filter((entry) => entry.size >= addlFreeSize(entries))
    .sort((a, b) => Math.sign(a - b));
  return sizableEntries[0];
});
