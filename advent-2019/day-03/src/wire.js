'use strict';
class Wire
{
  // Create a grid map of a wire's path. The grid key is a "Y,X" coordinate
  // string. Each grid value holds the number of steps the wire has
  // travelled from the origin. (Per the puzzle description, the origin
  // square is NOT included in the grid.)
  //
  // str: a string e.g. "R8,U5,L5,D3" describing the wire's path
  constructor(str)
  {
    this.segments = str.trim().split(/,/).map((seg) => Wire.str2seg(seg));
    this.grid = {};
    let y = 0, x = 0, steps = 0;
    this.segments.forEach((s) => {
      for (let i = 0; i < s.count; i++) {
        y += s.yi;
        x += s.xi;
        steps += 1;
        // "If a wire visits a position on the grid multiple times, use
        // the steps value from the first time it visits that position
        // when calculating the total value of a specific intersection."
        if (this.grid[`${y},${x}`] === undefined) {
          this.grid[`${y},${x}`] = steps;
        }
      }
    });
  }
  // Decode one segment of a wire's path e.g. "R8" into Y and X offsets
  // (step direction) and a step count.
  static str2seg(str)
  {
    let yi, xi;
    switch (str[0]) {
    case 'U': yi = -1; xi =  0; break;
    case 'D': yi =  1; xi =  0; break;
    case 'R': yi =  0; xi =  1; break;
    case 'L': yi =  0; xi = -1; break;
    }
    return {
      yi,
      xi,
      count: Number(str.slice(1)),
    };
  }
  // Find the intersection points between our wire and another wire.
  // Each intersection has a step count which is the sum of the steps
  // BOTH wires took from the origin to the intersection point.
  intersectionsWith(wire)
  {
    const tupler = (s) => s.split(/,/).map((e) => Number(e));
    return Object.keys(this.grid).reduce((intersections, k) => {
      if (wire.grid[k]) {
        const yx = tupler(k);
        intersections.push({
          y: yx[0],
          x: yx[1],
          steps: this.grid[k] + wire.grid[k],
        });
      }
      return intersections;
    }, []);
  }
  // Find the intersection point that's "closest" to the origin (by
  // Manhattan distance), and return the distance value.
  closestIntersectionWith(wire)
  {
    const manhattan = (y, x) => Math.abs(y) + Math.abs(x);
    return this.intersectionsWith(wire).reduce((min, i) => Math.min(min, manhattan(i.y, i.x)), Number.MAX_SAFE_INTEGER);
  }
  // Find the intersection point with the "shortest" signal path of
  // the two wires from the origin, and return the combined step count.
  shortestIntersectionWith(wire)
  {
    return this.intersectionsWith(wire).reduce((min, i) => Math.min(min, i.steps), Number.MAX_SAFE_INTEGER);
  }
}
module.exports = Wire;
