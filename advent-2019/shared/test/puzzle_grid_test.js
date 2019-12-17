'use strict';
const expect = require('chai').expect;
const PuzzleGrid = require('../src/puzzle_grid');
describe('puzzle grid constructor tests', () => {
  // TODO
  // should ensure grid key is an object with >= 2 valid entries
});
describe('puzzle grid get/set tests', () => {
  // TODO
  // should throw exception if coordinates [Y, X] is not an Array
  // should throw exception if coordinate Y & X are not numbers
  // should return `undefined` for spaces without content yet
});
describe('puzzle grid render tests', () => {
  // TODO
  // render() should be dump() but return an Array of strings
});
describe('puzzle grid parse tests', () => {
  // TODO
  // parse() should take Array of strings and set grid contents
  // [opposite of what render() does]
});
