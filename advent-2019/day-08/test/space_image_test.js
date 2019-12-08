'use strict';
const expect = require('chai').expect;
const SpaceImage = require('../src/space_image');
describe('space image constructor tests', () => {
  it('should parse 3x2 image correctly', () => {
    const image = new SpaceImage('123456789012\n', {width: 3, height: 2});
    expect(image.width).to.eql(3);
    expect(image.height).to.eql(2);
    expect(Array.isArray(image.layers)).to.be.true;
    expect(image.nLayers).to.eql(2);
    expect(image.layers[0].length).to.eql(6);
  });
  it('should throw an exception for missing options', () => {
    const call = () => { new SpaceImage('123456789012'); };
    expect(call).to.throw(Error, 'missing options');
  });
  it('should throw an exception for missing width parameter', () => {
    const call = () => { new SpaceImage('123456789012', {height: 2}); };
    expect(call).to.throw(Error, 'missing width');
  });
  it('should throw an exception for missing height parameter', () => {
    const call = () => { new SpaceImage('123456789012', {width: 3}); };
    expect(call).to.throw(Error, 'missing height');
  });
  it('should throw an exception for incomplete last layer', () => {
    const call = () => { new SpaceImage('12345678901', {width: 3, height: 2}); };
    expect(call).to.throw(Error, 'last layer incomplete');
  });
  it('should throw an exception for invalid characters', () => {
    const call = () => { new SpaceImage('123456789x12', {width: 3, height: 2}); };
    expect(call).to.throw(Error, 'non-digit characters');
  });
});
