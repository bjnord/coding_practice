#!/bin/sh
convert -delay 20 -loop 0 viz/frame000.pbm viz/frame000.pbm viz/frame000.pbm viz/frame000.pbm viz/frame000.pbm viz/frame0??.pbm viz/frame050.pbm viz/frame050.pbm viz/frame050.pbm viz/frame050.pbm viz/frame050.pbm viz/aoc2021-day20.gif
identify viz/aoc2021-day20.gif | head -1
