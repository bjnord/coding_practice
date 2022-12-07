'use strict';
const expect = require('chai').expect;
const device = require('../src/device');
const exampleInput = '$ cd /\n$ ls\ndir a\n14848514 b.txt\n8504156 c.dat\ndir d\n$ cd a\n$ ls\ndir e\n29116 f\n2557 g\n62596 h.lst\n$ cd e\n$ ls\n584 i\n$ cd ..\n$ cd ..\n$ cd d\n$ ls\n4060174 j\n8033020 d.log\n5626152 d.ext\n7214296 k\n';
const dirInput = '$ cd /\n$ ls\ndir a\n14848514 b.txt\n8504156 c.dat\ndir d\n';
describe('parsing tests', () => {
  it('should parse one level correctly', () => {
    const dir = device.parse(dirInput);
    expect(dir.name).to.equal('/');
    const files = ['b.txt', 'c.dat'];
    expect(dir.files.map((file) => file.name)).to.eql(files);
    const sizes = [14848514, 8504156];
    expect(dir.files.map((file) => file.size)).to.eql(sizes);
  });
  it('should parse entire tree correctly', () => {
    const expected = {
      name: '/',
      files: [
        {name: 'b.txt', size: 14848514},
        {name: 'c.dat', size: 8504156},
      ],
      dirs: [
        {
          name: 'a',
          files: [
            {name: 'f', size: 29116},
            {name: 'g', size: 2557},
            {name: 'h.lst', size: 62596},
          ],
          dirs: [
            {
              name: 'e',
              files: [
                {name: 'i', size: 584},
              ],
              dirs: [],
            }
          ],
        },
        {
          name: 'd',
          files: [
            {name: 'j', size: 4060174},
            {name: 'd.log', size: 8033020},
            {name: 'd.ext', size: 5626152},
            {name: 'k', size: 7214296},
          ],
          dirs: [],
        },
      ],
    };
    expect(device.parse(exampleInput)).to.eql(expected);
  });
});
describe('size calculation tests', () => {
  it('should calculate size of one level correctly', () => {
    const dir = device.parse(dirInput);
    const expected = [
      {name: '/', size: 14848514 + 8504156},
    ];
    expect(device.calculateSizes(dir)).to.eql(expected);
  });
  it('should calculate size of entire tree correctly', () => {
    const tree = device.parse(exampleInput);
    const expected = [
      {name: '/a/e/', size: 584},
      {name: '/a/', size: 94853},
      {name: '/d/', size: 24933642},
      {name: '/', size: 48381165},
    ];
    expect(device.calculateSizes(tree)).to.eql(expected);
  });
});
