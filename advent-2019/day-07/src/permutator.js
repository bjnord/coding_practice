'use strict';
// Return permutations of a set of choices.
//
// PARAMETERS
//   choices: Array of choices (elements can be any type)
//   nPicks:  how many choices to pick per permutation
//
// RETURNS
//   Set whose members are each an Array of permuted choices
//   Set.size will be P(nChoices,nPicks) = nChoices! / (nChoices-nPicks)!
const permute = (choices, nPicks) => {
  if (choices.length < 1) {
    throw new Error('Empty choices list');
  } else if ((nPicks < 0) || (nPicks > choices.length)) {
    throw new Error('Invalid number of picks');
  }
  // special cases at end of recursion chain:
  if (nPicks === 0) {
    return new Set();
  } else if (choices.length === 1) {
    return new Set([choices]);
  }
  //console.log(`nPicks=${nPicks} choices: ${choices}`);
  const permutations = choices.map((choice, i) => {
    const remainingChoices = choices.slice();
    remainingChoices.splice(i, 1);  // NB splice() returns removed element
    //console.log(`nPicks=${nPicks} i=${i} remainingChoices: ${remainingChoices}`);
    //console.dir(remainingChoices);
    // TODO hoist this out of map (to special cases); would simplify
    //      remaining code, which would always flatten
    if (nPicks === 1) {
      const ret = [choice];
      //console.log(`nPicks=${nPicks} i=${i} non-recursive return: ${ret}`);
      //console.dir(ret);
      return ret;
    } else {
      const remainingPermutations = Array.from(permute(remainingChoices, nPicks - 1));
      //console.log(`nPicks=${nPicks} i=${i} remainingPermutations: ${remainingPermutations}`);
      //console.dir(remainingPermutations);
      // prepend this level's choice to all child levels' permutations:
      const ret = remainingPermutations.map((p) => {
        p.unshift(choice);  // NB unshift() returns new length
        return p;
      });
      //console.log(`nPicks=${nPicks} i=${i} recursive return: ${ret}`);
      //console.dir(ret);
      return ret;
    }
  });
  if (Array.isArray(permutations[0][0])) {
    // TODO Node v11+ has Array.prototype.flat()
    // h/t <https://stackoverflow.com/a/10865042/291754>
    const flattened = [].concat.apply([], permutations);
    //console.log('flattened:');
    //console.dir(flattened);
    return new Set(flattened);
  } else {
    //console.log('permutations:');
    //console.dir(permutations);
    return new Set(permutations);
  }
};
exports.permute = permute;
