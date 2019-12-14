'use strict';
/** @module */
// TODO with all the side-effects and args-passing in calculate(),
//      this would be better as a class -- break processTopItem()
//      into multiple private methods for each step, etc.
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
 * Parse one line from the puzzle input.
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
/**
 * Calculate ORE required to produce 1 unit of the provided chemical type.
 *
 * @param {Map} inv - inventory of chemicals the refinery can produce
 * @param {object} product - item to produce, with `units` and `chem` fields
 *
 * @return {number}
 *   Returns amount of input ORE required.
 */
exports.calculate = (inv, product) => {
  let ore = 0;
  const stack = [product], remains = {};
  //console.debug('inventory:');
  //console.dir(inv);
  //console.debug('initial stack:');
  //console.dir(stack);
  while (stack.length > 0) {
    ore = processTopItem(inv, stack, ore, remains);
  }
  return ore;
};
const processTopItem = (inv, stack, ore, remains) => {
  const oItem = stack.pop();
  if (oItem.chem === 'ORE') {
    //console.debug(`use ${oItem.units} ore, new ore=${ore + oItem.units}`);
    return ore + oItem.units;
  }
  // first use up any banked amount on hand:
  if (remains[oItem.chem] >= oItem.units) {
    //console.debug(`use ${oItem.units} units of "${oItem.chem}" on hand`);
    remains[oItem.chem] -= oItem.units;
    //console.debug(`...leaving ${remains[oItem.chem]} units banked`);
    return ore;
  } else if (remains[oItem.chem] > 0) {
    //console.debug(`use all ${remains[oItem.chem]} units of "${oItem.chem}" on hand`);
    oItem.units -= remains[oItem.chem];
    remains[oItem.chem] = 0;
  }
  // if not enough, find the formula needed to produce more:
  const formula = inv.get(oItem.chem);
  //console.debug(`formula for "${oItem.chem}":`);
  //console.dir(formula);
  if (!formula) {
    throw new Error(`formula not found to produce chemical "${oItem.chem}"`);
  }
  // if we need more units than the formula provides, scale it:
  const multiple = (oItem.units > formula.units) ? Math.ceil(oItem.units / formula.units) : 1;
  const oUnits = formula.units * multiple;
  const iItems = formula.req.map((iItem) => ({units: iItem.units * multiple, chem: iItem.chem}));
  iItems.forEach((iItem) => stack.push(iItem));
  // the formula may produce more than we need; if so, bank it:
  const oRemainder = oUnits - oItem.units;
  if (oRemainder > 0) {
    remains[oItem.chem] = (remains[oItem.chem] || 0) + oRemainder;
    //console.debug(`banked ${remains[oItem.chem]} units of "${oItem.chem}"`);
  }
  //console.debug('processed stack:');
  //console.dir(stack);
  //console.debug('remains:');
  //console.dir(remains);
  //console.debug(`ore=${ore}`);
  return ore;
};
