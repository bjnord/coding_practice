'use strict';
const expect = require('chai').expect;
const ShipState = require('../src/ship_state');

const breachOutput = [
  '== Hull Breach ==',
  'You got in through a hole in the floor here. To keep your ship from also freezing, the hole has been sealed.',
  '',
  'Doors here lead:',
  '- north',
  '- south',
  '- west',
  '',
];
const hallOutput = [
  '== Hallway ==',
  "This area has been optimized for something; you're just not quite sure what.",
  '',
  'Doors here lead:',
  '- north',
  '- south',
  '',
  'Items here:',
  '- hologram',
  '',
];
const deliOutput = [
  '== West Side Deli ==',
  'This delicatessen has delicious eats!',
  '',
  'Doors here lead:',
  '- east',
  '',
  'Items here:',
  '- salami on rye',
  '- potato chips',
  '- jelly donut',
  '',
];
const cantError = [
  "You can't go that way.",
  '',
];
const stillCantError = [
  "You still can't go that way.",
  '',
];

describe('starship parsing tests', () => {
  let parseState;
  beforeEach(() => {
    parseState = new ShipState('104,89,104,111,104,117,104,46,104,10,104,10,104,67,104,111,104,109,104,109,104,97,104,110,104,100,104,63,104,10,3,100,99');
  });
  it('should parse new state correctly [example #1]', () => {
    parseState.parse(breachOutput);
    expect(parseState.message).to.be.undefined;
    expect(parseState.location).to.eql('Hull Breach');
    expect(parseState.description).to.eql('You got in through a hole in the floor here. To keep your ship from also freezing, the hole has been sealed.');
    expect(parseState.doorsHere).to.eql(['north', 'south', 'west']);
    expect(parseState.itemsHere).to.eql([]);
  });
  it('should parse new state correctly [example #2]', () => {
    parseState.parse(hallOutput);
    expect(parseState.message).to.be.undefined;
    expect(parseState.location).to.eql('Hallway');
    expect(parseState.description).to.eql("This area has been optimized for something; you're just not quite sure what.");
    expect(parseState.doorsHere).to.eql(['north', 'south']);
    expect(parseState.itemsHere).to.eql(['hologram']);
  });
  it('should parse new state correctly [example #3]', () => {
    parseState.parse(deliOutput);
    expect(parseState.message).to.be.undefined;
    expect(parseState.location).to.eql('West Side Deli');
    expect(parseState.description).to.eql('This delicatessen has delicious eats!');
    expect(parseState.doorsHere).to.eql(['east']);
    expect(parseState.itemsHere).to.eql(['salami on rye', 'potato chips', 'jelly donut']);
  });
  it('should parse state update correctly [example #1]', () => {
    parseState.parse(breachOutput);
    parseState.parse(cantError);
    expect(parseState.message).to.eql("You can't go that way.");
    expect(parseState.location).to.eql('Hull Breach');
    expect(parseState.description).to.eql('You got in through a hole in the floor here. To keep your ship from also freezing, the hole has been sealed.');
    expect(parseState.doorsHere).to.eql(['north', 'south', 'west']);
    expect(parseState.itemsHere).to.eql([]);
  });
  it('should parse state update correctly [example #2]', () => {
    parseState.parse(hallOutput);
    parseState.parse(cantError);
    expect(parseState.message).to.eql("You can't go that way.");
    expect(parseState.location).to.eql('Hallway');
    expect(parseState.description).to.eql("This area has been optimized for something; you're just not quite sure what.");
    expect(parseState.doorsHere).to.eql(['north', 'south']);
    expect(parseState.itemsHere).to.eql(['hologram']);
  });
  it('should parse state update correctly [example #3]', () => {
    parseState.parse(deliOutput);
    parseState.parse(stillCantError);
    expect(parseState.message).to.eql("You still can't go that way.");
    expect(parseState.location).to.eql('West Side Deli');
    expect(parseState.description).to.eql('This delicatessen has delicious eats!');
    expect(parseState.doorsHere).to.eql(['east']);
    expect(parseState.itemsHere).to.eql(['salami on rye', 'potato chips', 'jelly donut']);
  });
});
