'use strict';
const expect = require('chai').expect;
const nBugs = require('../src/n_fold_bugs');

const initialState = {state: 0b0000100100110010100110000, lines: [
  '....#',
  '#..#.',
  '#.?##',
  '..#..',
  '#....',
]};
const testState = {state: 0b0111100100110010100110000, lines: [
  '....#',
  '#..#.',
  '#.?##',
  '..#..',
  '####.',
]};

describe('n-fold bugs parse tests [puzzle example]', () => {
  it('parses the initial state correctly', () => {
    expect(nBugs.parseOne(initialState.lines)).to.eql(initialState.state);
  });
  it('parses the test state correctly', () => {
    expect(nBugs.parseOne(testState.lines)).to.eql(testState.state);
  });
  it('parses an invalid grid as expected', () => {
    const badLines = [
      '.....',
      '... .',
      '..?..',
      '#....',
      '.#...',
    ];
    expect(nBugs.parseOne(badLines)).to.be.NaN;
  });
});
describe('n-fold bugs format tests [puzzle example]', () => {
  it('formats the initial state correctly', () => {
    expect(nBugs.formatOne(initialState.state)).to.eql(initialState.lines);
  });
  it('formats the test state correctly', () => {
    expect(nBugs.formatOne(testState.state)).to.eql(testState.lines);
  });
});
describe('n-fold bugs edge count tests [puzzle example]', () => {
  it('counts bugs on the top edge correctly', () => {
    expect(nBugs.edgeCount(testState.state, 1, 0)).to.eql(1);
  });
  it('counts bugs on the bottom edge correctly', () => {
    expect(nBugs.edgeCount(testState.state, -1, 0)).to.eql(4);
  });
  it('counts bugs on the left edge correctly', () => {
    expect(nBugs.edgeCount(testState.state, 0, 1)).to.eql(3);
  });
  it('counts bugs on the right edge correctly', () => {
    expect(nBugs.edgeCount(testState.state, 0, -1)).to.eql(2);
  });
  it('should throw an exception if [Y, X] combination is not valid', () => {
    let call = () => { nBugs.edgeCount(0, 0, 0); };
    expect(call).to.throw(Error, 'only one of [Y, X] can be 0');
    call = () => { nBugs.edgeCount(0, 1, -1); };
    expect(call).to.throw(Error, 'only one of [Y, X] can be non-0');
  });
});
describe('n-fold bugs count-adjacent tests [puzzle example]', () => {
  let plusAbove, plusBelow;
  beforeEach(() => {
    plusAbove = {number: 0, state: initialState.state, above: {number: -1, state: testState.state}};
    plusBelow = {number: 0, state: testState.state, below: {number: 1, state: initialState.state}};
  });
  it('treats [2, 2] as undefined', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [2, 2])).to.be.undefined;
  });
  // "Tile G has four adjacent tiles: B, F, H, and L."
  it('counts [1, 1] correctly (4 from this level)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [1, 1])).to.eql(1);
  });
  it('counts [3, 3] correctly (4 from this level)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [3, 3])).to.eql(2);
  });
  // "Tile D has four adjacent tiles: 8, C, E, and I."
  it('counts [0, 3] correctly (3 from this level, 1 from grid above)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [0, 3])).to.eql(2);
  });
  it('counts [4, 2] correctly (3 from this level, 1 from grid above)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [4, 2])).to.eql(2);
  });
  it('counts [1, 4] correctly (3 from this level, 1 from grid above)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [1, 4])).to.eql(4);
  });
  // "Tile E has four adjacent tiles: 8, D, 14, and J."
  it('counts [0, 4] correctly (2 from this level, 2 from grid above)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [0, 4])).to.eql(1);
  });
  it('counts [0, 0] correctly (2 from this level, 2 from grid above)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [0, 0])).to.eql(1);
  });
  it('counts [4, 4] correctly (2 from this level, 2 from grid above)', () => {
    expect(nBugs.countOfAdjacentAt(plusAbove, [4, 4])).to.eql(2);
  });
  // "Tile N has eight adjacent tiles: I, O, S, and five tiles within the
  // sub-grid marked ?."
  it('counts [2, 3] correctly (3 from this level, 5 from grid below)', () => {
    expect(nBugs.countOfAdjacentAt(plusBelow, [2, 3])).to.eql(4);
  });
  it('counts [2, 1] correctly (3 from this level, 5 from grid below)', () => {
    expect(nBugs.countOfAdjacentAt(plusBelow, [2, 1])).to.eql(4);
  });
  it('counts [1, 2] correctly (3 from this level, 5 from grid below)', () => {
    expect(nBugs.countOfAdjacentAt(plusBelow, [1, 2])).to.eql(2);
  });
  it('counts [3, 2] correctly (3 from this level, 5 from grid below)', () => {
    expect(nBugs.countOfAdjacentAt(plusBelow, [3, 2])).to.eql(2);
  });
});
describe('n-fold bugs event tests [puzzle example]', () => {
  let plusAbove, plusBelow;
  beforeEach(() => {
    plusAbove = {number: 0, state: initialState.state, above: {number: -1, state: testState.state}};
    plusBelow = {number: 0, state: testState.state, below: {number: 1, state: initialState.state}};
  });
  it('treats [2, 2] as undefined', () => {
    expect(nBugs.eventAt(plusAbove, [2, 2])).to.be.undefined;
  });
  it('finds [1, 1] event correctly (4 from this level)', () => {  // empty, 1
    expect(nBugs.eventAt(plusAbove, [1, 1])).to.eql('spawn');
  });
  it('finds [1, 3] event correctly (4 from this level)', () => {  // bug, 1
    expect(nBugs.eventAt(plusAbove, [1, 3])).to.eql('stasis');
  });
  it('finds [3, 3] event correctly (4 from this level)', () => {  // empty, 2
    expect(nBugs.eventAt(plusAbove, [3, 3])).to.eql('spawn');
  });
  it('finds [0, 3] event correctly (3 from this level, 1 from grid above)', () => {  // empty, 2
    expect(nBugs.eventAt(plusAbove, [0, 3])).to.eql('spawn');
  });
  it('finds [2, 4] event correctly (3 from this level, 1 from grid above)', () => {  // bug, 2
    expect(nBugs.eventAt(plusAbove, [2, 4])).to.eql('death');
  });
  it('finds [1, 4] event correctly (3 from this level, 1 from grid above)', () => {  // empty, 4
    expect(nBugs.eventAt(plusAbove, [1, 4])).to.eql('stasis');
  });
  it('finds [0, 4] event correctly (2 from this level, 2 from grid above)', () => {  // bug, 1
    expect(nBugs.eventAt(plusAbove, [0, 4])).to.eql('stasis');
  });
  it('finds [0, 0] event correctly (2 from this level, 2 from grid above)', () => {  // empty, 1 
    expect(nBugs.eventAt(plusAbove, [0, 0])).to.eql('spawn');
  });
  it('finds [4, 4] event correctly (2 from this level, 2 from grid above)', () => {  // empty, 2
    expect(nBugs.eventAt(plusAbove, [4, 4])).to.eql('spawn');
  });
  it('finds [2, 3] event correctly (3 from this level, 5 from grid below)', () => {  // bug, 4
    expect(nBugs.eventAt(plusBelow, [2, 3])).to.eql('death');
  });
  it('finds [2, 1] event correctly (3 from this level, 5 from grid below)', () => {  // empty, 4
    expect(nBugs.eventAt(plusBelow, [2, 1])).to.eql('stasis');
  });
  it('finds [1, 2] event correctly (3 from this level, 5 from grid below)', () => {  // empty, 2
    expect(nBugs.eventAt(plusBelow, [1, 2])).to.eql('spawn');
  });
  it('finds [3, 2] event correctly (3 from this level, 5 from grid below)', () => {  // bug, 2
    expect(nBugs.eventAt(plusBelow, [3, 2])).to.eql('death');
  });
});
describe('n-fold bugs generate level-creation tests', () => {
  it('should not create level below if all center-adjacent squares are empty', () => {
    const level = {number: 0, state: 0b0};
    nBugs.generateOne(level);
    expect(level.below).to.be.undefined;
  });
  it('should create empty level below if any center-adjacent square has a bug [east of center]', () => {
    const level = {number: 0, state: 0b0000000000010000000000000};
    //console.debug('east of center:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    nBugs.generateOne(level);
    expect(level.below.number).to.eql(1);
    expect(level.below.above).to.eql(level);
    expect(level.below.state).to.eql(0b0);
  });
  it('should create empty level below if any center-adjacent square has a bug [south of center]', () => {
    const level = {number: 1, state: 0b0000000100000000000000000};
    //console.debug('south of center:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    nBugs.generateOne(level);
    expect(level.below.number).to.eql(2);
    expect(level.below.above).to.eql(level);
    expect(level.below.state).to.eql(0b0);
  });
  it('should not create level above if all edge squares are empty', () => {
    const level = {number: 0, state: 0b0};
    nBugs.generateOne(level);
    expect(level.above).to.be.undefined;
  });
  it('should create level above if any edge square has a bug [north edge]', () => {
    const level = {number: 0, state: 0b0000000000000000000001000};
    //console.debug('north edge:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    nBugs.generateOne(level);
    expect(level.above.number).to.eql(-1);
    expect(level.above.below).to.eql(level);
    expect(level.above.state).to.eql(0b0);
  });
  it('should create level above if any edge square has a bug [north edge]', () => {
    const level = {number: -1, state: 0b0000000001000000000000000};
    //console.debug('west edge:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    nBugs.generateOne(level);
    expect(level.above.number).to.eql(-2);
    expect(level.above.below).to.eql(level);
    expect(level.above.state).to.eql(0b0);
  });
});

/*
 * "The center tile is drawn as ? to indicate the next recursive grid. Call
 * this level 0; the grid within this one is level 1, and the grid that
 * contains this one is level -1. Then, after ten minutes, the grid at each
 * level would look like this:"
 */
const puzzleLevels = [
  [ // Depth -5:  [highest "above"]
    '..#..',  // 0b0010001010100000101000100
    '.#.#.',
    '..?.#',
    '.#.#.',
    '..#..',
  ], [  // Depth -4:
    '...#.',
    '...##',
    '..?..',
    '...##',
    '...#.',
  ], [  // Depth -3:
    '#.#..',
    '.#...',
    '..?..',
    '.#...',
    '#.#..',
  ], [  // Depth -2:
    '.#.##',
    '....#',
    '..?.#',
    '...##',
    '.###.',
  ], [  // Depth -1:
    '#..##',
    '...##',
    '..?..',
    '...#.',
    '.####',
  ], [  // Depth 0:
    '.#...',  // 0b0000000000000101101000010
    '.#.##',
    '.#?..',
    '.....',
    '.....',
  ], [  // Depth 1:
    '.##..',
    '#..##',
    '..?.#',
    '##.##',
    '#####',
  ], [  // Depth 2:
    '###..',
    '##.#.',
    '#.?..',
    '.#.##',
    '#.#..',
  ], [  // Depth 3:
    '..###',
    '.....',
    '#.?..',
    '#....',
    '#...#',
  ], [  // Depth 4:
    '.###.',
    '#..#.',
    '#.?..',
    '##.#.',
    '.....',
  ], [  // Depth 5:  [lowest "below"]
    '####.',  // 0b0000001111010010100101111
    '#..#.',
    '#.?#.',
    '####.',
    '.....',
  ]
];
describe('n-fold bugs multi-level parse and count tests [puzzle example]', () => {
  let level0;
  before(() => {
    level0 = nBugs.parseMultiLevel(puzzleLevels, -5);
    //const lines = nBugs.formatMultiLevel(level0);
    //lines.forEach((line) => console.debug(line));
  });
  it('should parse Depth 0 correctly', () => {
    expect(level0.state).to.eql(0b0000000000000101101000010);
  });
  it('should parse Depth -5 correctly', () => {
    const levelN5 = level0.above.above.above.above.above;
    expect(levelN5.state).to.eql(0b0010001010100000101000100);
  });
  it('should parse Depth 5 correctly', () => {
    const level5 = level0.below.below.below.below.below;
    expect(level5.state).to.eql(0b0000001111010010100101111);
  });
  it('should get a correct total count', () => {
    expect(nBugs.countMultiLevel(level0)).to.eql(99);
  });
});

// puzzle example, after 1 minute:
const aboveState1 = {state: 0b0000000100010000010000000, lines: [  // Layer -1
  '.....',
  '..#..',
  '..?#.',
  '..#..',
  '.....',
]};
const zeroState1 = {state: 0b0011011011100110111101001, lines: [  // Layer 0
  '#..#.',
  '####.',
  '##?.#',
  '##.##',
  '.##..',
]};
const belowState1 = {state: 0b1111110000100001000010000, lines: [  // Layer 1
  '....#',
  '....#',
  '..?.#',
  '....#',
  '#####',
]};
describe('n-fold bugs multi-level generate and iterate tests [puzzle example, 1 generation]', () => {
  let level;
  before(() => {
    level = {number: 0, state: initialState.state};
    //console.log('initial multi-level state:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    nBugs.iterateMultiLevel(level, 1);
  });
  it('should matched the parsed state after 1 iteration', () => {
    //console.log('multi-level state after 1 iteration:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    expect(level.above.state).to.eql(aboveState1.state);
    expect(level.state).to.eql(zeroState1.state);
    expect(level.below.state).to.eql(belowState1.state);
  });
  it('should get a correct total count after 1 iteration', () => {
    expect(nBugs.countMultiLevel(level)).to.eql(3+15+9);
  });
});

// puzzle example, after 2 minutes:
const aboveState2 = {state: 0b0010001010100000101000100, lines: [  // Layer -1
  '..#..',
  '.#.#.',
  '..?.#',
  '.#.#.',
  '..#..',
]};
const zeroState2 = {state: 0b0000001000000000000000000, lines: [  // Layer 0
  '.....',
  '.....',
  '..?..',
  '...#.',
  '.....',
]};
const belowState2 = {state: 0b0000001111010010100101111, lines: [  // Layer 1
  '####.',
  '#..#.',
  '#.?#.',
  '####.',
  '.....',
]};
describe('n-fold bugs multi-level generate and iterate tests [puzzle example, 2 generations]', () => {
  let level;
  before(() => {
    level = {number: 0, state: initialState.state};
    //console.log('initial multi-level state:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    nBugs.iterateMultiLevel(level, 2);
  });
  it('should matched the parsed state after 2 iterations', () => {
    //console.log('multi-level state after 2 iterations:');
    //const lines = nBugs.formatMultiLevel(level);
    //lines.forEach((line) => console.debug(line));
    //console.log('expected above state:');
    //aboveState2.lines.forEach((line) => console.debug(line));
    //console.log('-----');
    expect(level.above.state).to.eql(aboveState2.state);
    expect(level.state).to.eql(zeroState2.state);
    expect(level.below.state).to.eql(belowState2.state);
  });
  it('should get a correct total count after 2 iterations', () => {
    expect(nBugs.countMultiLevel(level)).to.eql(7+1+12);
  });
});
describe('n-fold bugs multi-level generate and iterate tests [puzzle example, 10 generations]', () => {
  let initialLevel;
  before(() => {
    initialLevel = {number: 0, state: initialState.state};
    //console.log('initial multi-level state:');
    //const lines = nBugs.formatMultiLevel(initialLevel);
    //lines.forEach((line) => console.debug(line));
  });
  it('should get a correct total count after 10 iterations', () => {
    nBugs.iterateMultiLevel(initialLevel, 10);
    //console.log('multi-level state after 10 iterations:');
    //const lines = nBugs.formatMultiLevel(initialLevel);
    //lines.forEach((line) => console.debug(line));
    expect(nBugs.countMultiLevel(initialLevel)).to.eql(99);
  });
});
