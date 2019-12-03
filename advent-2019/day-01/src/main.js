const Module = require('../src/module');
const fs = require('fs');
const input = fs.readFileSync('input/input.txt', 'utf8');
const module_masses = input.trim().split(/\s+/);
const summer = (acc, i) => acc + i;
const total = module_masses
  .map(mass => {
    var module = new Module;
    return module.mass2fuel(mass);
  })
  .reduce(summer);
console.log('expected answer is:          3405721');
console.log(`sum of fuel requirements is: ${total}`);
