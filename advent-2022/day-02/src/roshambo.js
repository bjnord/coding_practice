'use strict';
/** @module */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Array.Object}
 *   Returns a list of roshambo rounds.
 */
exports.parse = (input) => {
  return input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `A Y`)
 *
 * @return {Object}
 *   Returns a roshambo round.
 */
exports.parseLine = (line) => {
  const moves = line.trim().split(/\s/);
  return {
    opponent: moves[0].charCodeAt(0) - 65,
    player: moves[1].charCodeAt(0) - 88,
  };
};

exports.scoreRounds = (rounds) => {
  return rounds.map((round) => module.exports.score(round))
    .reduce((total, score) => total + score);
};

exports.score = (round) => {
  const l = round.player;
  const r = round.opponent;
  const score =
    ((l === 0) && (r === 2)) ? 6 : (
      ((l === 2) && (r === 0)) ? 0 : (
        (l > r) ? 6 : (
          (l === r) ? 3 : 0
        )
      )
    );
  return (l + 1) + score;
};
