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
  parentDistance(fromName, toName)
  {
    let count = 0;
    for (let o = this.orbitMap.get(fromName); o; ) {
      if (o.parentName === toName) {
        return count + 1;
      }
      o = this.orbitMap.get(o.parentName);
      count++;
    }
    return undefined;
  }
  transferCount(fromName, toName)
  {
    // the transfer count is the sum of the distances to the common ancestor
    // of from & to
    for (let fromDist = 0, o = this.orbitMap.get(fromName); o; ) {
      fromDist++;
      // OPTIMIZE calculating toDist every time is inefficient - O(n^2)
      // could precalculate a map of parents & their distances - O(n)
      const toDist = this.parentDistance(toName, o.parentName);
      if (toDist) {
        return fromDist + toDist;
      }
      o = this.orbitMap.get(o.parentName);
    }
    return undefined;
  }
}
module.exports = OrbitMap;
