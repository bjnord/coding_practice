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
  it('should throw exception for bad first line', () => {
    const badInput = 'ls\ndir a\n14848514 b.txt\n8504156 c.dat\ndir d\n';
    const badParseFn = () => { device.parse(badInput); };
    expect(badParseFn).to.throw(SyntaxError);
  });
});
describe('size calculation tests', () => {
  it('should calculate size of one level correctly', () => {
    const dir = device.parse(dirInput);
    const expected = [
      {path: '/', size: 14848514 + 8504156},
    ];
    expect(device.calculateDirectorySizes(dir)).to.eql(expected);
  });
  it('should calculate size of entire tree correctly', () => {
    const tree = device.parse(exampleInput);
    const expected = [
      {path: '/a/e/', size: 584},
      {path: '/a/', size: 94853},
      {path: '/d/', size: 24933642},
      {path: '/', size: 48381165},
    ];
    expect(device.calculateDirectorySizes(tree)).to.eql(expected);
  });
});
describe('directory find tests', () => {
  it('should find entries matching path', () => {
    const entries = [
      {path: '/a/e/', size: 584},
      {path: '/a/', size: 94853},
      {path: '/d/', size: 24933642},
      {path: '/', size: 48381165},
    ];
    expect(device.childEntriesOfPath(entries, '/a/')).to.eql(entries.slice(0, 1));
    expect(device.childEntriesOfPath(entries, '/d/')).to.eql([]);
    expect(device.childEntriesOfPath(entries, '/')).to.eql(entries.slice(1, 3));
  });
  it('should find the correct directory to delete', () => {
    const tree = device.parse(exampleInput);
    const expected = {path: '/d/', size: 24933642};
    expect(device.directoryToDelete(tree)).to.eql(expected);
  });
});
