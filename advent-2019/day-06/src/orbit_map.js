'use strict';
const Orbiter = require('../src/orbiter');
class OrbitMap
{
  constructor(str)
  {
    const orbiters = str.trim().split(/\n/).map((s) => new Orbiter(s));
    this.orbitMap = new Map(orbiters.map((o) => [o.name, o]));
  }
  get directOrbitCount()
  {
    return this.orbitMap.size;
  }
  parentOf(name)
  {
    const parent = this.orbitMap.get(name);
    return parent ? parent.parentName : undefined;
  }
  get totalOrbitCount()
  {
    // h/t <https://stackoverflow.com/a/35341828/291754>
    return [...this.orbitMap.keys()].reduce((count, name) => count + this.totalOrbitCountOf(name), 0);
  }
  totalOrbitCountOf(name)
  {
    let count = 0;
    for (let o = this.orbitMap.get(name); o; ) {
      o = this.orbitMap.get(o.parentName);
      count++;
    }
    return count;
  }
}
module.exports = OrbitMap;
