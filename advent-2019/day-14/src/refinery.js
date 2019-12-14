'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input (e.g. `7 A, 1 E => 1 FUEL`) separated by `\n`
 *
 * @return {Map}
 *   Returns an inventory of all chemicals the refinery can produce. The map
 *   is keyed by output chemical type (string), and its values are objects
 *   with the following fields:
 *   - `units` - amount of chemical produced (number)
 *   - `req` - list of required input chemicals (Array), each one an object
 *     with `units` and `chem` fields
 */
exports.parse = (input) => {
  return input.trim().split(/\n/)
    .map((line) => module.exports.parseLine(line))
    .reduce((inv, item) => {
      const outChem = item.chem;
      delete item.chem;
      if (inv.get(outChem)) {
        throw new Error(`duplicate output chemical "${outChem}"`);
      }
      inv.set(outChem, item);
      return inv;
    }, new Map());
};
/**
 * Parse one line of coordinates from the puzzle input.
 *
 * @param {string} line - line of puzzle input (e.g. `7 A, 1 E => 1 FUEL`)
 *
 * @return {object}
 *   Returns an object with the following fields:
 *   - `units` - amount of chemical produced (number)
 *   - `chem` - type of chemical produced (string)
 *   - `req` - list of required input chemicals (Array), each one an object
 *     with `units` and `chem` fields
 */
exports.parseLine = (line) => {
  const re = /^(.*)=>(.*)$/;
  const ioMatch = re.exec(line.trim());
  if (!ioMatch) {
    throw new Error('invalid line format');
  }
  const output = parseChemUnits(ioMatch[2]);
  const req = ioMatch[1].split(/,/).map((cu) => parseChemUnits(cu));
  return {
    units: output.units,
    chem: output.chem,
    req
  };
};
const parseChemUnits = (str) => {
  const tok = str.trim().split(/\s+/);
  if (tok.length !== 2) {
    throw new Error(`invalid units/chemical "${str.trim()}"`);
  }
  const units = parseInt(tok[0]);
  if (isNaN(units)) {
    throw new Error(`invalid units "${tok[0]}"`);
  }
  return {
    units,
    chem: tok[1],
  };
};
