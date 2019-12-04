class Wire
{
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
        // If a wire visits a position on the grid multiple times, use
        // the steps value from the first time it visits that position
        // when calculating the total value of a specific intersection.
        if (this.grid[`${y},${x}`] === undefined) {
          this.grid[`${y},${x}`] = steps;
        }
      }
    });
  }
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
  intersectionsWith(wire)
  {
    let intersections = [];
    const tupler = (s) => s.split(/,/).map((e) => Number(e));
    // TODO RF can .map() be used while rejecting all but intersections?
    Object.keys(this.grid).forEach((k) => {
      if (wire.grid[k]) {
        const yx = tupler(k);
        intersections.push({
          y: yx[0],
          x: yx[1],
          steps: this.grid[k] + wire.grid[k],
        });
      }
    });
    return intersections;
  }
  closestIntersectionWith(wire)
  {
    const manhattan = (y, x) => Math.abs(y) + Math.abs(x);
    return this.intersectionsWith(wire).reduce((min, i) => Math.min(min, manhattan(i.y, i.x)), Number.MAX_SAFE_INTEGER);
  }
  shortestIntersectionWith(wire)
  {
    return this.intersectionsWith(wire).reduce((min, i) => Math.min(min, i.steps), Number.MAX_SAFE_INTEGER);
  }
}
module.exports = Wire;
