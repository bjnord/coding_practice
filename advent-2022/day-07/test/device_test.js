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
});
