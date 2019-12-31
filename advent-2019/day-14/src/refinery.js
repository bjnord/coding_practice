'use strict';
const math = require('mathjs');

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
 * Calculate `ORE` required to produce the provided chemical type.
 *
 * @param {Map} inv - inventory of chemicals the refinery can produce
 * @param {object} product - item to produce, with `units` and `chem` fields
 * @param {object} [remains={}] - remains from last round (if any)
 *
 * @return {number}
 *   Returns amount of input `ORE` required.
 */
exports.calculate = (inv, product, remains = {}) => {
  let ore = 0;
  const stack = [product];
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
    if (remains[oItem.chem] > oItem.units) {
      //console.debug(`use ${oItem.units} units of "${oItem.chem}" on hand`);
      remains[oItem.chem] -= oItem.units;
      //console.debug(`...leaving ${remains[oItem.chem]} units banked`);
    } else {
      //console.debug(`use all ${oItem.units} units of "${oItem.chem}" on hand`);
      delete remains[oItem.chem];
    }
    return ore;
  } else if (remains[oItem.chem] > 0) {
    //console.debug(`use all ${remains[oItem.chem]} units of "${oItem.chem}" on hand`);
    oItem.units -= remains[oItem.chem];
    delete remains[oItem.chem];
    //console.debug(`...but ${oItem.units} more units are needed`);
  }
  // if not enough, find the formula needed to produce more:
  const formula = inv.get(oItem.chem);
  //console.debug(`formula for "${oItem.chem}":`);
  //console.dir(formula);
  /* istanbul ignore if */
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
/**
 * Calculate amount of fuel that can be produced from the provided amount
 * of `ORE`.
 *
 * @param {Map} inv - inventory of chemicals the refinery can produce
 * @param {number} ore - amount of `ORE` on hand
 *
 * @return {number}
 *   Returns the amount of fuel which can be produced.
 */
exports.fuelFromOre = (inv, ore, debug = false) => {
  const frac = module.exports.oreFractions(inv);
  const decFuel = math.number(math.divide(ore, frac['FUEL']));
  /* istanbul ignore if */
  if (debug) {
    const ratio = math.format(frac['FUEL']).split('/');
    console.debug(`ORE/FUEL ratio: ${ratio} decFuel=${decFuel}`);
  }
  // due to rounding etc. we may not be able to make the last fuel unit:
  const fuelCount = Math.floor(decFuel) - 1;
  const fracOreUsed = math.multiply(fuelCount, frac['FUEL']);
  const remainingOre = ore - Math.floor(math.number(fracOreUsed));
  /* istanbul ignore if */
  if (debug) {
    console.debug(`from ${ore} ORE, made ${fuelCount} FUEL leaving ore=${remainingOre} ORE`);
  }
  // ...so we calculate ORE for the last one and see if we have enough:
  const remains = {};
  let rFuelCount = 0, rOre = 0;
  const ore1 = module.exports.calculate(inv, {units: 1, chem: 'FUEL'}, remains);
  if ((remainingOre - (rOre + ore1)) < 0) {
    /* istanbul ignore if */
    if (debug) {
      console.debug('OUT OF ORE');
    }
  } else {
    rOre += ore1;
    rFuelCount++;
    /* istanbul ignore if */
    if (debug) {
      console.debug(`rem round ${rFuelCount}, ore=${ore1}/${rOre}, remains: ${Object.keys(remains).map((k) => `${k}: ${remains[k]}`)}`);
    }
  }
  /* istanbul ignore if */
  if (debug) {
    console.debug(`from ${remainingOre} ORE, made ${rFuelCount} FUEL leaving ore=${remainingOre - rOre} ORE`);
    console.debug(`final FUEL count=${fuelCount + rFuelCount}`);
  }
  return fuelCount + rFuelCount;
};
const _oreFractionOf = (inv, frac, chem) => {
  if (frac[chem]) {
    return;
  }
  if (chem === 'ORE') {
    frac['ORE'] = math.fraction(1, 1);
    return;
  }
  const formula = inv.get(chem);
  /* istanbul ignore if */
  if (!formula) {
    throw new Error(`formula not found to produce chemical "${chem}"`);
  }
  const reqOre = formula.req.map((item) => {
    _oreFractionOf(inv, frac, item.chem);
    return math.multiply(item.units, frac[item.chem]);
  });
  const reqSum = reqOre.reduce((sum, ore) => math.add(sum, ore), math.fraction(0, 1));
  // TODO can be math.divide(reqSum, formula.units);
  frac[chem] = math.multiply(reqSum, math.fraction(1, formula.units));
};
/**
 * Calculate fractional (exact) amount of `ORE` required to produce each
 * chemical in our inventory, and to produce `FUEL`.
 *
 * In the returned object, `frac['FUEL']` is the `ORE/FUEL` ratio, as a
 * fractional (exact) value.
 *
 * @param {Map} inv - inventory of chemicals the refinery can produce
 *
 * @return {object}
 *   Returns an object whose keys are chemicals (including `FUEL`), and
 *   whose values are the fractional amount of `ORE` required to produce
 *   that chemical.
 */
exports.oreFractions = (inv) => {
  const frac = {};
  _oreFractionOf(inv, frac, 'FUEL');
  return frac;
};
