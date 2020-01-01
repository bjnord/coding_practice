'use strict';
/** @module */
/**
 * Perform cycle detection on a stepwise function, using
 * [Floyd's "Tortoise and Hare" algorithm](https://en.wikipedia.org/wiki/Cycle%5Fdetection#Floyd%27s%5FTortoise%5Fand%5FHare).
 *
 * @param {function} f - function which transforms the current state to the
 *   next state in the sequence [`f(x0)` returns `x1`]
 * @param {function} eq - function which detects equality of two states
 *   [`eq(a, b)` returns `true` if states are equal]
 * @param x0 - initial state (of the type `f(x)` expects)
 *
 * @return {Array}
 *   Returns the "lambda and mu" from Floyd's algorithm:
 *   - lambda - length of the cycle found
 *   - mu - index of the first occurrence of the cycle
 */
exports.run = (f, eq, x0) => {
  // Main phase of algorithm: finding a repetition x_i = x_2i.
  // The hare moves twice as quickly as the tortoise and
  // the distance between them increases by 1 at each step.
  // Eventually they will both be inside the cycle and then,
  // at some point, the distance between them will be
  // divisible by the period λ.
  let tortoise = f(x0);
  let hare = f(f(x0));
  while (!eq(tortoise, hare)) {
    tortoise = f(tortoise);
    hare = f(f(hare));
  }

  // At this point the tortoise position, ν, which is also equal
  // to the distance between hare and tortoise, is divisible by
  // the period λ. So hare moving in circle one step at a time, 
  // and tortoise (reset to x0) moving towards the circle, will 
  // intersect at the beginning of the circle. Because the 
  // distance between them is constant at 2ν, a multiple of λ,
  // they will agree as soon as the tortoise reaches index μ.

  // Find the position μ of first repetition.  
  let mu = 0;
  tortoise = x0;
  while (!eq(tortoise, hare)) {
    tortoise = f(tortoise);
    hare = f(hare);   // Hare and tortoise move at same speed
    mu += 1;
  }
 
  // Find the length of the shortest cycle starting from x_μ
  // The hare moves one step at a time while tortoise is still.
  // lam is incremented until λ is found.
  let lam = 1;
  hare = f(tortoise);
  while (!eq(tortoise, hare)) {
    hare = f(hare);
    lam += 1;
  }
 
  return [lam, mu];
};
