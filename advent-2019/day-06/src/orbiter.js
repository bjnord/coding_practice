'use strict';
class Orbiter
{
  constructor(str)
  {
    const s = str.trim();
    const o = s.split(')');
    if (o.length !== 2) {
      throw new Error (`invalid orbit ${s}`);
    }
    this.name = o[1];
    this.parentName = o[0];
  }
};
module.exports = Orbiter;
