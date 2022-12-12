'use strict';
/** @module hill */
/**
 * Parse the puzzle input.
 *
 * @param {string} input - lines of puzzle input separated by `\n`
 *
 * @return {Object}
 *   Returns the height map.
 */
exports.parse = (input) => {
  const rows = input.trim().split(/\n/).map((line) => module.exports.parseLine(line));
  const startRowI = rows.findIndex((row) => 'start' in row);
  const endRowI = rows.findIndex((row) => 'end' in row);
  return {
    height: rows.length,
    width: rows[0].heights.length,
    start: [startRowI, rows[startRowI].start],
    end: [endRowI, rows[endRowI].end],
    rows
  };
};
/**
 * Parse one line from the puzzle input.
 *
 * @param {string} line - line of puzzle input (_e.g._ `Sabqponm`)
 *
 * @return {Array.number}
 *   Returns the corresponding row of the height map.
 */
exports.parseLine = (line) => {
  const h = {heights: []};
  for (let i = 0; i < line.length; i++) {
    let cc = line.charCodeAt(i);
    if (cc === 83) {  // S
      h.start = i;
      cc = 97;  // a (1)
    } else if (cc === 69) {  // E
      h.end = i;
      cc = 122;  // z (26)
    }
    h.heights.push(cc - 96);
  }
  return h;
};

exports.neighbors = ((grid, pos) => {
  const deltas = [[-1, 0], [1, 0], [0, -1], [0, 1]];
  const neighbors = [];
  for (const delta of deltas) {
    const nPos = [pos[0], pos[1]];
    nPos[0] += delta[0];
    nPos[1] += delta[1];
    if ((nPos[0] >= 0) && (nPos[0] < grid.height)) {
      if ((nPos[1] >= 0) && (nPos[1] < grid.width)) {
        neighbors.push(nPos);
      }
    }
  }
  return neighbors;
});

exports.weight = ((grid, pos1, pos2) => {
  const height1 = grid.rows[pos1[0]].heights[pos1[1]];
  const height2 = grid.rows[pos2[0]].heights[pos2[1]];
  if (height2 > height1 + 1) {
    return 999999999;
  } else {
    return 1;
  }
});

// Pseudocode from [this article](https://brilliant.org/wiki/dijkstras-short-path-finder/)
//
//    dist[source]  := 0                     // Distance from source to source is set to 0
//    for each vertex v in Graph:            // Initializations
//        if v ≠ source
//            dist[v]  := infinity           // Unknown distance function from source to each node set to infinity
//        add v to Q                         // All nodes initially in Q
//
//    while Q is not empty:                  // The main loop
//        v := vertex in Q with min dist[v]  // In the first run-through, this vertex is the source node
//        remove v from Q 
//
//        for each neighbor u of v:           // where neighbor u has not yet been removed from Q.
//            alt := dist[v] + length(v, u)
//            if alt < dist[u]:               // A shorter path to u has been found
//                dist[u]  := alt            // Update distance of u 
//
//    return dist[]

const posKey = ((pos) => '' + pos[0] + ',' + pos[1]);

exports.dijkstra = ((grid) => {
  const dist = new Array(grid.height * grid.width).fill(999999999);
  dist[grid.start[0] * grid.width + grid.start[1]] = 0;

  const q = {};
  for (let y = 0; y < grid.height; y++) {
    for (let x = 0; x < grid.width; x++) {
      q[posKey([y, x])] = [y, x];
    }
  }
  //console.debug(`q keys length=${Object.keys(q).length}`);

  while (Object.keys(q).length > 0) {
    const posDistPairs = Object.keys(q)
      .map((k) => [q[k], dist[q[k][0] * grid.width + q[k][1]]])
      .sort((a, b) => Math.sign(a[1] - b[1]));
    //console.debug('posDistPairs:');
    //console.dir(posDistPairs);
    const pos = posDistPairs[0][0];
    //console.debug(`minDist pos=${pos[0]},${pos[1]}`);
    //console.dir(pos);
    delete q[posKey(pos)];

    for (const nPos of module.exports.neighbors(grid, pos)) {
      //console.debug(`  neighbor=${nPos[0]},${nPos[1]}`);
      //console.dir(nPos);
      const alt = dist[pos[0] * grid.width + pos[1]]
        + module.exports.weight(grid, pos, nPos);
      if (alt < dist[nPos[0] * grid.width + nPos[1]]) {
        //console.debug(`    shorter alt=${alt}`);
        dist[nPos[0] * grid.width + nPos[1]] = alt;
      }
    }
  }

  const steps = dist[grid.end[0] * grid.width + grid.end[1]];
  //console.debug(`steps=${steps}  dist[]:`);
  //console.dir(dist);

  return steps;
});
