class Wire
{
  constructor(str)
  {
    this.segments = str.trim().split(/,/).map((seg) => Wire.str2seg(seg));
    this.grid = {};
    let y = 0, x = 0, steps = 0;
    this.segments.forEach((s) => {
      // TODO RF move this into str2seg()
      let yi, xi;
      switch (s.dir) {
        case 'U': yi = -1; xi =  0; break;
        case 'D': yi =  1; xi =  0; break;
        case 'R': yi =  0; xi =  1; break;
        case 'L': yi =  0; xi = -1; break;
      }
      for (let i = 0; i < s.count; i++) {
        y += yi;
        x += xi;
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
    return {
      dir: str[0],
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
    let closest = 99999999999999;
    this.intersectionsWith(wire).forEach((i) => {
      let distance = Math.abs(i.y) + Math.abs(i.x);
      if (distance < closest) {  // TODO RF min() would be tidier
        closest = distance;
      }
    });
    return closest;
  }
  shortestIntersectionWith(wire)
  {
    let shortest = 99999999999999;
    this.intersectionsWith(wire).forEach((i) => {
      if (i.steps < shortest) {  // TODO RF min() would be tidier
        shortest = i.steps;
      }
    });
    return shortest;
  }
}
module.exports = Wire;
