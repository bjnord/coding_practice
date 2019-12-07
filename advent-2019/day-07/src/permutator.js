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
  } else if (nPicks === 1) {
    const ret = new Set(choices.map((c) => [c]));
    //console.log('short-circuit return:');
    //console.dir(ret);
    return ret;
  }
  //console.log(`nPicks=${nPicks} choices: ${choices}`);
  const permutations = choices.map((choice, i) => {
    const remainingChoices = choices.slice();
    remainingChoices.splice(i, 1);  // NB splice() returns removed element
    //console.log(`nPicks=${nPicks} i=${i} remainingChoices: ${remainingChoices}`);
    //console.dir(remainingChoices);
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
  });
  // TODO Node v11+ has Array.prototype.flat()
  // h/t <https://stackoverflow.com/a/10865042/291754>
  const flattened = [].concat.apply([], permutations);
  //console.log('flattened:');
  //console.dir(flattened);
  return new Set(flattened);
};
exports.permute = permute;
