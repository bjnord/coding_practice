class Wire
{
  constructor(str)
  {
    this.segments = str.trim().split(/,/).map((seg) => Wire.str2seg(seg));
    this.grid = {};
    let y = 0, x = 0;
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
        this.grid[`${y},${x}`] = true;
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
}
module.exports = Wire;
