# Equations for Day 24

```
Hailstone A: 19, 13, 30 @ -2, 1, -2
Hailstone D: 12, 31, 28 @ -1, -2, -1
Hailstones' paths will cross outside the test area (at x=6.2, y=19.4).
```

## Line slope equations

### Two dimensions

Ignoring the Z axis, Hailstone A will include the following two positions:

- at `t = 0`: `x0 = 19, y0 = 13`
- at `t = 1`: `x1 = 17, y1 = 14`

In the equation `y = m * x + b`:

- the slope `m` is:
  - `m = dy / dx`
    - ("rise over run": diff in y coord / diff in x coord)
  - `m = 1 / -2`
    - (`y` changes by `1` for every `-2` that `x` changes)
  - `m = -1/2`
- the offset `b` (`y`-intersect) is:
  - `y0 = m * x0 + b`
  - `13 = -1/2 * 19 + b`
  - `b = 13 - (-1/2 * 19)`
  - `b = 22.5`
  - `b = y0 - (m * x0)`
- checking `t = 1` we get:
  - `b = 14 - (-1/2 * 17)`
  - `b = 22.5`

Ignoring the Z axis, Hailstone D will include the following two positions:

- at `t = 0`: `x0 = 12, y0 = 31`
- at `t = 1`: `x1 = 11, y1 = 29`

In the equation `y = m * x + b`:

- the slope `m` is:
  - `m = dy / dx`
    - ("rise over run": diff in y coord / diff in x coord)
  - `m = -2 / -1`
    - (`y` changes by `-2` for every `-1` that `x` changes)
  - `m = 2`
- the offset `b` (`y`-intersect) is:
  - `y0 = m * x0 + b`
  - `31 = 2 * 12 + b`
  - `b = 31 - (2 * 12)`
  - `b = 7`
  - `b = y0 - (m * x0)`
- checking `t = 1` we get:
  - `b = 29 - (2 * 11)`
  - `b = 7`

## Intersection equations

### Two dimensions

The two hailstone lines can be written in `y = m * x + b` form:

- Generalized:
  - `y = (dy / dx) * x + (y0 - (dy / dx) * x0)`
- Hailstone A: 19, 13, 30 @ -2, 1, -2
  - `y = (1 / -2) * x + (13 - ((1 / -2) * 19))`
  - `y = -1/2 * x + (13 - (-1/2 * 19))`
  - `y = -1/2 * x + (13 - (-9.5))`
  - `y = -1/2 * x + 22.5`
    - _i.e._ `m = -1/2` and `b = 22.5`
- Hailstone D: 12, 31, 28 @ -1, -2, -1
  - `y = (-2 / -1) * x + (31 - ((-2 / -1) * 12))`
  - `y = 2 * x + (31 - (2 * 12))`
  - `y = 2 * x + (31 - 24)`
  - `y = 2 * x + 7`
    - _i.e._ `m = 2` and `b = 7`

Setting `y` equal we can derive these formulas:

- `am = ady / adx`
- `ab = ay0 - (am * ax0)`
- `bm = bdy / bdx`
- `bb = by0 - (bm * bx0)`
- `am * x + ab = bm * x + bb`
  - `am * x = bm * x + bb - ab`
  - `am * x - (bm * x) = bb - ab`
  - `x * am - (x * bm) = bb - ab`
  - `x * (am - bm) = bb - ab`
  - `x = (bb - ab) / (am - bm)`
- `y = am * x + ab` (either A or B will work)

So here is the `x, y` intersection point for A and B:

- `am = ady / adx`
  - `am = -1/2`
- `ab = ay0 - (am * ax0)`
  - `ab = 13 - (-1/2 * 19)`
  - `ab = 22.5`
- `bm = bdy / bdx`
  - `bm = 2`
- `bb = by0 - (bm * bx0)`
  - `bb = 31 - (2 * 12)`
  - `bb = 7`
- `x = (bb - ab) / (am - bm)`
  - `x = (7 - 22.5) / (-1/2 - 2)`
  - `x = (-15.5) / (-2.5)`
  - `x = 6.2`
- `y = am * x + ab`
  - `y = -1/2 * 6.2 + 22.5`
  - `y = -3.1 + 22.5`
  - `y = 19.4`
