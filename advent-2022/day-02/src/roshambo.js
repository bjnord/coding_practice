'use strict';
const math = require('../../shared/src/math');
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
/**
 * Determine the outcome of a roshambo round (strategy type 1).
 *
 * In this strategy type, the `round.player` represents the
 * play made:
 * - 0 for Rock
 * - 1 for Paper
 * - 2 for Scissors
 *
 * @param {Object} round - roshambo round (with `opponent` and
 *   `player` members)
 *
 * @return {number}
 *   Returns the outcome of the roshambo round:
 *   - 0 for Loss
 *   - 1 for Draw
 *   - 2 for Win
 */
exports.outcomeForPlay = (round) => {
  return math.mod((round.player - round.opponent + 1), 3);
};
/**
 * Calculate score for all roshambo rounds (strategy type 1).
 *
 * @param {Array.Object} rounds - list of roshambo rounds
 *
 * @return {number}
 *   Returns the total score for all roshambo rounds.
 */
exports.scoreRounds = (rounds) => {
  return rounds.map((round) => module.exports.score(round))
    .reduce((total, score) => total + score);
};
/**
 * Calculate score for one roshambo round (strategy type 1).
 *
 * In this strategy type, the `round.player` represents the
 * play made.
 *
 * "The score for a single round is the score for the shape you selected
 * (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the
 * outcome of the round (0 if you lost, 3 if the round was a draw, and
 * 6 if you won)."
 *
 * @param {Object} round - roshambo round
 *
 * @return {number}
 *   Returns the score for the roshambo round.
 */
exports.score = (round) => {
  const shapeScore = round.player + 1;
  const outcomeScore = module.exports.outcomeForPlay(round) * 3;
  return shapeScore + outcomeScore;
};
/**
 * Determine the play needed to produce a given outcome for a roshambo
 * round (strategy type 2).
 *
 * In this strategy type, the `round.player` represents the
 * desired outcome:
 * - 0 for Loss
 * - 1 for Draw
 * - 2 for Win
 *
 * @param {Object} round - roshambo round (with `opponent` and
 *   `player` members)
 *
 * @return {number}
 *   Returns the required play to produce the desired outcome:
 *   - 0 for Rock
 *   - 1 for Paper
 *   - 2 for Scissors
 */
exports.playForOutcome = (round) => {
  return math.mod((round.player + round.opponent - 1), 3);
};
/**
 * Calculate score for all roshambo rounds (strategy type 2).
 *
 * @param {Array.Object} rounds - list of roshambo rounds
 *
 * @return {number}
 *   Returns the total score for all roshambo rounds.
 */
exports.scoreRounds2 = (rounds) => {
  return rounds.map((round) => module.exports.score2(round))
    .reduce((total, score) => total + score);
};
/**
 * Calculate score for one roshambo round (strategy type 2).
 *
 * In this strategy type, the `round.player` represents the
 * desired outcome.
 *
 * "The score for a single round is the score for the shape you selected
 * (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the
 * outcome of the round (0 if you lost, 3 if the round was a draw, and
 * 6 if you won)."
 *
 * @param {Object} round - roshambo round
 *
 * @return {number}
 *   Returns the score for the roshambo round.
 */
exports.score2 = (round) => {
  const shapeScore = module.exports.playForOutcome(round) + 1;
  const outcomeScore = round.player * 3;
  return shapeScore + outcomeScore;
};
