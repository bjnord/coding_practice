'use strict';
const expect = require('chai').expect;
const fs = require('fs');
const Starship = require('../src/starship');
const input = fs.readFileSync('input/input.txt', 'utf8');

describe('starship constructor tests', () => {
  it('should have correct initial location', () => {
    const starship = new Starship(input);
    expect(starship.location).to.eql('Hull Breach');
  });
});
describe('starship search tests', () => {
  let starship;
  before(() => {
    starship = new Starship(input);
    starship.search();
  });
  it('should finish back at initial location', () => {
    expect(starship.location).to.eql('Hull Breach');
  });
  it('should set checkpointPath correctly', () => {
    expect(starship.checkpointPath).to.eql(['north', 'north', 'west', 'north', 'east', 'east']);
  });
  it('should set sensorDirection correctly', () => {
    expect(starship.sensorDirection).to.eql('north');
  });
});
describe('starship move tests', () => {
  let starship;
  beforeEach(() => {
    starship = new Starship(input);
  });
  it('should follow path correctly [Hot Chocolate Fountain]', () => {
    starship.move(['north', 'north', 'west', 'south', 'east']);
    expect(starship.location).to.eql('Hot Chocolate Fountain');
  });
  it('should follow path correctly [Warp Drive Maintenance]', () => {
    starship.move(['north', 'west', 'south']);
    expect(starship.location).to.eql('Warp Drive Maintenance');
  });
});
// this is the full puzzle (what src/main.js does):
describe('starship airlock password test', () => {
  it('should get the correct airlock password', () => {
    const starship = new Starship(input);
    starship.search();
    starship.move(starship.checkpointPath);
    starship.moveThroughSensor(starship.sensorDirection);
    expect(starship.airlockPassword).to.eql('1090529280');
  });
});
