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

exports.outcomeForPlay = (round) => {
  return math.mod((round.player - round.opponent + 1), 3);
};

exports.scoreRounds = (rounds) => {
  return rounds.map((round) => module.exports.score(round))
    .reduce((total, score) => total + score);
};

/*
 * "The score for a single round is the score for the shape you selected
 * (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the
 * outcome of the round (0 if you lost, 3 if the round was a draw, and
 * 6 if you won)."
 */
exports.score = (round) => {
  const shapeScore = round.player + 1;
  const outcomeScore = module.exports.outcomeForPlay(round) * 3;
  return shapeScore + outcomeScore;
};

exports.playForOutcome = (round) => {
  return math.mod((round.player + round.opponent - 1), 3);
};

exports.scoreRounds2 = (rounds) => {
  return rounds.map((round) => module.exports.score2(round))
    .reduce((total, score) => total + score);
};

/*
 * "The score for a single round is the score for the shape you selected
 * (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the
 * outcome of the round (0 if you lost, 3 if the round was a draw, and
 * 6 if you won)."
 */
exports.score2 = (round) => {
  const shapeScore = module.exports.playForOutcome(round) + 1;
  const outcomeScore = round.player * 3;
  return shapeScore + outcomeScore;
};
