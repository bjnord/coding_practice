'use strict';
const expect = require('chai').expect;
const ShipState = require('../src/ship_state');
const TestAsciiIntcode = require('../../shared/src/test_ascii_intcode');

/*
 * This is a perfect use case for test mocks. The ASCII Intcode machine (our
 * puzzle input) will never change, so we can easily catalog all the types of
 * output line groups, and make sure our ShipState state/interface parses them
 * all correctly.
 */

/*****************
 * INITIAL STATE *
 *****************/

const initialOutput = [
  '== Hull Breach ==',
  'You got in through a hole in the floor here. To keep your ship from also freezing, the hole has been sealed.',
  '',
  'Doors here lead:',
  '- north',
  '- south',
  '- west',
  '',
];
describe('ship state constructor tests', () => {
  it('should take correctly [item here]', () => {
    const mockMachine = new TestAsciiIntcode([], [
      initialOutput,
    ]);
    const initialState = new ShipState(mockMachine);
    expect(initialState.message).to.be.undefined;
    expect(initialState.location).to.eql('Hull Breach');
    expect(initialState.description).to.eql('You got in through a hole in the floor here. To keep your ship from also freezing, the hole has been sealed.');
    expect(initialState.doorsHere).to.eql(['north', 'south', 'west']);
    expect(initialState.itemsHere).to.eql([]);
  });
});

/*****************
 * MOVE          *
 *****************/

const moveDirection = 'north';
const noItemsHereOutput = [
  '== Navigation ==',
  'Status: Stranded. Please supply measurements from fifty stars to recalibrate.',
  '',
  'Doors here lead:',
  '- north',
  '- south',
  '- west',
  '',
];
const itemsHereOutput = [
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
const cantMoveDirection = 'east';
const cantMoveOutput = [
  "You can't go that way.",
  '',
];
const sensorDirection = 'north';
const sensorFailOutput = [
  '== Pressure-Sensitive Floor ==',
  'Analyzing...',
  '',
  'Doors here lead:',
  '- south',
  '',
  'A loud, robotic voice says "Alert! Droids on this ship are heavier than the detected value!" and you are ejected back to the checkpoint.',
  '',
  '',
  '',
  '== Security Checkpoint ==',
  'In the next room, a pressure-sensitive floor will verify your identity.',
  '',
  'Doors here lead:',
  '- north',
  '- west',
  '',
];
const sensorPassOutput = [
  '== Pressure-Sensitive Floor ==',
  'Analyzing...',
  '',
  'Doors here lead:',
  '- south',
  '',
  'A loud, robotic voice says "Analysis complete! You may proceed." and you enter the cockpit.',
  'Santa notices your small droid, looks puzzled for a moment, realizes what has happened, and radios your ship directly.',
  '"Oh, hello! You should be able to get in by typing 1090529280 on the keypad at the main airlock."',
];
describe('ship state move tests', () => {
  it('should move correctly [no items]', () => {
    const mockMachine = new TestAsciiIntcode([moveDirection], [
      initialOutput,
      noItemsHereOutput,
    ]);
    const moveState = new ShipState(mockMachine);
    expect(moveState.move(moveDirection)).to.be.true;
    expect(moveState.message).to.be.undefined;
    expect(moveState.location).to.eql('Navigation');
    expect(moveState.description).to.eql('Status: Stranded. Please supply measurements from fifty stars to recalibrate.');
    expect(moveState.doorsHere).to.eql(['north', 'south', 'west']);
    expect(moveState.itemsHere).to.eql([]);
  });
  it('should move correctly [items here]', () => {
    const mockMachine = new TestAsciiIntcode([moveDirection], [
      initialOutput,
      itemsHereOutput,
    ]);
    const moveState = new ShipState(mockMachine);
    expect(moveState.move(moveDirection)).to.be.true;
    expect(moveState.message).to.be.undefined;
    expect(moveState.location).to.eql('Hallway');
    expect(moveState.description).to.eql("This area has been optimized for something; you're just not quite sure what.");
    expect(moveState.doorsHere).to.eql(['north', 'south']);
    expect(moveState.itemsHere).to.eql(['hologram']);
  });
});
describe("ship state can't-move tests", () => {
  it('should leave state unaffected [no items]', () => {
    const mockMachine = new TestAsciiIntcode([moveDirection, cantMoveDirection], [
      initialOutput,
      noItemsHereOutput,
      cantMoveOutput,
    ]);
    const moveState = new ShipState(mockMachine);
    expect(moveState.move(moveDirection)).to.be.true;
    expect(moveState.move(cantMoveDirection)).to.be.false;
    expect(moveState.message).to.be.eql("You can't go that way.");
    expect(moveState.location).to.eql('Navigation');
    expect(moveState.description).to.eql('Status: Stranded. Please supply measurements from fifty stars to recalibrate.');
    expect(moveState.doorsHere).to.eql(['north', 'south', 'west']);
    expect(moveState.itemsHere).to.eql([]);
  });
  it('should leave state unaffected [items here]', () => {
    const mockMachine = new TestAsciiIntcode([moveDirection, cantMoveDirection], [
      initialOutput,
      itemsHereOutput,
      cantMoveOutput,
    ]);
    const moveState = new ShipState(mockMachine);
    expect(moveState.move(moveDirection)).to.be.true;
    expect(moveState.move(cantMoveDirection)).to.be.false;
    expect(moveState.message).to.be.eql("You can't go that way.");
    expect(moveState.location).to.eql('Hallway');
    expect(moveState.description).to.eql("This area has been optimized for something; you're just not quite sure what.");
    expect(moveState.doorsHere).to.eql(['north', 'south']);
    expect(moveState.itemsHere).to.eql(['hologram']);
  });
});
describe('ship state move-to-sensor tests', () => {
  it('should move correctly [weight incorrect]', () => {
    const mockMachine = new TestAsciiIntcode([sensorDirection], [
      initialOutput,
      sensorFailOutput,
    ]);
    const moveState = new ShipState(mockMachine);
    expect(moveState.move(sensorDirection)).to.be.false;
    expect(moveState.message).to.be.eql('A loud, robotic voice says "Alert! Droids on this ship are heavier than the detected value!" and you are ejected back to the checkpoint.');
    expect(moveState.messageDetail.some((line) => line && (line.trim().length > 0))).to.be.false;
    expect(moveState.location).to.eql('Security Checkpoint');
    expect(moveState.description).to.eql('In the next room, a pressure-sensitive floor will verify your identity.');
    expect(moveState.doorsHere).to.eql(['north', 'west']);
    expect(moveState.itemsHere).to.eql([]);
    expect(moveState.airlockPassword).to.be.undefined;
  });
  it('should move correctly and find password [weight correct]', () => {
    const mockMachine = new TestAsciiIntcode([sensorDirection], [
      initialOutput,
      sensorPassOutput,
    ]);
    const moveState = new ShipState(mockMachine);
    expect(moveState.move(sensorDirection)).to.be.true;
    expect(moveState.message).to.be.undefined;
    expect(moveState.messageDetail.length).to.eql(3);
    expect(moveState.messageDetail[0]).to.match(/You may proceed\."/);
    expect(moveState.messageDetail[1]).to.match(/^Santa notices /);
    expect(moveState.messageDetail[2]).to.match(/^"Oh, hello!/);
    expect(moveState.airlockPassword).to.eql('1090529280');
  });
  it('should get correct room state [weight correct]', () => {
    const mockMachine = new TestAsciiIntcode([sensorDirection], [
      initialOutput,
      sensorPassOutput,
    ]);
    const moveState = new ShipState(mockMachine);
    expect(moveState.move(sensorDirection)).to.be.true;
    expect(moveState.location).to.eql('Pressure-Sensitive Floor');
    expect(moveState.description).to.eql('Analyzing...');
    expect(moveState.doorsHere).to.eql(['south']);
    expect(moveState.itemsHere).to.eql([]);
  });
});

/*****************
 * TAKE          *
 *****************/

const takeItem = 'manifold';
const takeOutput = [
  'You take the manifold.',
  '',
];
const toxicTakeItem = 'molten lava';
const toxicTakeOutput = [
  'You take the molten lava.',
  '',
  'The molten lava is way too hot! You melt!',
  '',
];
const cantTakeItem = 'wooden nickel';
const cantTakeOutput = [
  "You don't see that item here.",
  '',
];
describe('ship state take tests', () => {
  it('should take correctly [item here]', () => {
    const mockMachine = new TestAsciiIntcode([`take ${takeItem}`], [
      initialOutput,
      takeOutput,
    ]);
    const takeState = new ShipState(mockMachine);
    expect(takeState.take(takeItem)).to.be.true;
    expect(takeState.message).to.be.undefined;
  });
  it('should take correctly [toxic item here]', () => {
    const mockMachine = new TestAsciiIntcode([`take ${toxicTakeItem}`], [
      initialOutput,
      toxicTakeOutput,
    ]);
    const toxicTakeState = new ShipState(mockMachine);
    expect(toxicTakeState.take(toxicTakeItem)).to.be.false;
    expect(toxicTakeState.message).to.match(/You melt!/);
    expect(toxicTakeState.messageDetail.some((line) => line && (line.trim().length > 0))).to.be.false;
  });
  it('should take correctly [no item here]', () => {
    const mockMachine = new TestAsciiIntcode([`take ${cantTakeItem}`], [
      initialOutput,
      cantTakeOutput,
    ]);
    const cantTakeState = new ShipState(mockMachine);
    expect(cantTakeState.take(cantTakeItem)).to.be.false;
    expect(cantTakeState.message).to.eql("You don't see that item here.");
  });
});

/*****************
 * DROP          *
 *****************/

const dropItem = 'fuel cell';
const dropOutput = [
  'You drop the fuel cell.',
  '',
];
const cantDropItem = 'everything';
const cantDropOutput = [
  "You don't have that item.",
  '',
];
describe('ship state drop tests', () => {
  it('should drop correctly [have item]', () => {
    const mockMachine = new TestAsciiIntcode([`drop ${dropItem}`], [
      initialOutput,
      dropOutput,
    ]);
    const dropState = new ShipState(mockMachine);
    expect(dropState.drop(dropItem)).to.be.true;
    expect(dropState.message).to.be.undefined;
  });
  it('should drop correctly [no item]', () => {
    const mockMachine = new TestAsciiIntcode([`drop ${cantDropItem}`], [
      initialOutput,
      cantDropOutput,
    ]);
    const cantDropState = new ShipState(mockMachine);
    expect(cantDropState.drop(cantDropItem)).to.be.false;
    expect(cantDropState.message).to.eql("You don't have that item.");
  });
});

/*****************
 * INVENTORY     *
 *****************/

const inventoryOutput = [
  'Items in your inventory:',
  '- tambourine',
  '- hologram',
  '- fuel cell',
  '',
];
const emptyInventoryOutput = [
  "You aren't carrying any items.",
  '',
];
describe('ship state inventory tests', () => {
  it('should take inventory correctly [some items]', () => {
    const mockMachine = new TestAsciiIntcode(['inv'], [
      initialOutput,
      inventoryOutput,
    ]);
    const invState = new ShipState(mockMachine);
    expect(invState.inventory).to.eql(['tambourine', 'hologram', 'fuel cell']);
  });
  it('should take inventory correctly [no items]', () => {
    const mockMachine = new TestAsciiIntcode(['inv'], [
      initialOutput,
      emptyInventoryOutput,
    ]);
    const invState = new ShipState(mockMachine);
    expect(invState.inventory).to.eql([]);
  });
  it('should get memoized inventory correctly', () => {
    const mockMachine = new TestAsciiIntcode(['inv'], [
      initialOutput,
      inventoryOutput,
    ]);
    const invState = new ShipState(mockMachine);
    const firstInventory = invState.inventory.slice();
    expect(invState.inventory).to.eql(firstInventory);
  });
});
