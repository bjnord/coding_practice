'use strict';

class CardOfInterest
{
  /**
   * Create a new deck of N cards, in "factory order", for which we're only
   * interested in the card at one given position.
   *
   * @param {number} nCards - number of cards in the deck
   * @param {number} cardPos - the position of the only card of interest
   *
   * @return {CardOfInterest}
   *   Returns a new CardOfInterest class object.
   */
  constructor(nCards, cardPos)
  {
    if (nCards < 2) {
      throw new Error('invalid number of cards');
    } else if (cardPos < 0) {
      throw new Error('invalid card position');
    } else if (cardPos >= nCards) {
      throw new Error(`invalid card position for a ${nCards}-card deck`);
    }
    /**
     * the number of cards in the deck
     * @member {number}
     */
    this.nCards = nCards;
    /**
     * the position of the card of interest
     * @member {number}
     */
    this.cardPos = cardPos;
    // private: our [A,B] linear function stack [f(x) = a*x + b]
    this._abStack = [[1, 0]];  // identity
    // private: our composed [A,B] linear function
    this._abComposed = undefined;
  }
  /**
   * the card at the position of interest
   * @member {Array}
   */
  get card()
  {
    if (!this._abComposed) {
      this._abComposed = this._composeFunction(this._abStack);
    }
    const a = this._abComposed[0];
    const b = this._abComposed[1];
    //console.debug(`composed A=${a} B=${b} for pos=${this.cardPos}`);
    return CardOfInterest._axb(a, this.cardPos, b, this.nCards);
  }
  // private: create a composed function from a function stack
  _composeFunction(abStack)
  {
    while (abStack.length > 1) {
      const fnG = abStack.shift();  // "outer" function g() of g(f(x))
      const fnF = abStack.shift();  // "inner" function f() of g(f(x))
      // "Given two functions `f = a*x+b` and `g = c*x+d`,
      // composition `g(f(x))` is `c*a*x + c*b + d`."
      const newA = CardOfInterest._axb(fnG[0], fnF[0], 0, this.nCards);
      const newB = CardOfInterest._axb(fnG[0], fnF[1], fnG[1], this.nCards);
      abStack.unshift([newA, newB]);
    }
    return abStack.shift();
  }
  // private: calculate ax+b % d
  // NOTE arguments are Number, return is Number
  static _axb(a, x, b, d)
  {
    return Number(CardOfInterest._negrem(BigInt(a) * BigInt(x) + BigInt(b), BigInt(d)));
  }
  // private: handle modulo of negatives
  // NOTE arguments are BigInt, return is BigInt
  static _negrem(a, b)
  {
    if (a < 0) {
      return b - (-a % b);
    } else {
      return a % b;
    }
  }
  /**
   * Deal cards into a new stack, reversing their order.
   */
  dealIntoNewStack()
  {
    this._abStack.push([-1, this.nCards - 1]);
    this._abComposed = undefined;
  }
  /**
   * Cut the cards at position N.
   *
   * - If N is **positive**, cut the top N cards, and move them to the
   *   bottom (in the same order).
   * - If N is **negative**, cut the bottom -N cards, and move them to
   *   the top (in the same order).
   *
   * @param {number} n - the position at which to cut the cards
   */
  cutCards(n)
  {
    this._abStack.push([1, n]);
    this._abComposed = undefined;
  }
  /**
   * Redeal the cards in a modulo-N pattern.
   *
   * _e.g._ For 10 cards and `n=3`, the position 0 card is placed at
   * position 0, the position 1 card is placed at position 3, the position
   * 4 card is placed at position 2, etc.
   *
   * @param {number} n - the deal increment
   */
  dealWithIncrement(n)
  {
    if (n < 1) {
      throw new Error('invalid increment');
    }
    this._abStack.push([CardOfInterest._m(n, this.nCards), 0]);
    this._abComposed = undefined;
  }
  // private: "inverse modulo"-type function
  // D = deck size
  // M = (1+D*x)/N with the first x=0.. that makes M come out evenly
  static _m(n, nCards)
  {
    for (let x = 0; ; x++) {
      const numerator = 1 + nCards * x;
      if ((numerator % n) === 0) {
        return numerator / n;
      }
    }
  }
  /**
   * Shuffle the cards using a list of our techniques, repeated the given
   * number of times.
   *
   * See `doTechnique()` for a list of techniques.
   *
   * @param {string} techniques - `\n`-separated list of techniques to perform
   * @param {number} repeat - the number of times to repeat the techniques list
   */
  doTechniquesNTimes(techniques, repeat)
  {
    // create the meta-function:
    this.doTechniques(techniques);
    this._abComposed = this._composeFunction(this._abStack);
    // compose the meta-function N times to create a meta-meta-function:
    // (1) compose the squared functions for each 2^n:
    let bitFunctions = {0: this._abComposed.slice()};
    //console.debug(`composed i=${0} b=0b${0b1.toString(2)}`);
    for (let i = 1, b = 0b10; b <= repeat; i++, b *= 2) {
      const twoBits = [bitFunctions[i-1].slice(), bitFunctions[i-1].slice()];
      bitFunctions[i] = this._composeFunction(twoBits);
      //console.debug(`composed i=${i} b=0b${b.toString(2)}`);
    }
    // TIL JavaScript bitwise operations are limited to 32 bits, and
    // all numbers are stored as IEEE 754 double-precision floats, so
    // integers are limited to 53 bits
    const repeatBottom = repeat % 0x100000000;
    const repeatTop = Math.floor(repeat / 0x100000000);
    // (2) compose a function matching bits in repeat:
    const abMetaStack = [];
    let b = 0b1;
    for (let i = 0; i < 53; i++) {
      if ((i < 32) && (repeatBottom & b)) {
        abMetaStack.push(bitFunctions[i].slice());
        //console.debug(`used i=${i} from bottom`);
      } else if ((i >= 32) && (repeatTop & b)) {
        abMetaStack.push(bitFunctions[i].slice());
        //console.debug(`used i=${i} from top`);
      } else {
        //console.debug(`didnt use i=${i}`);
      }
      if (i === 31) {
        if (repeatTop === 0) {
          break;
        } else {
          b = 0b1;
        }
      } else {
        b *= 2;
      }
    }
    this._abComposed = this._composeFunction(abMetaStack);
  }
  /**
   * Shuffle the cards using a list of our techniques.
   *
   * See `doTechnique()` for a list of techniques.
   *
   * @param {string} techniques - `\n`-separated list of techniques to perform
   */
  doTechniques(techniques)
  {
    techniques.trim().split(/\n/).forEach((t) => this.doTechnique(t));
  }
  /**
   * Perform one shuffling technique.
   *
   * This can be one of:
   * - "`deal into new stack`" (see `dealIntoNewStack()`)
   * - "`cut <n>`" where `<n>` is a number (see `cutCards(n)`)
   * - "`deal with increment <n>`" where `<n>` is a number (see `dealWithIncrement(n)`)
   *
   * @param {string} technique - the technique to perform
   */
  doTechnique(technique)
  {
    let m;
    if (technique === 'deal into new stack') {
      this.dealIntoNewStack();
    } else if ((m = technique.match(/^cut (-?\d+)$/))) {
      this.cutCards(Number(m[1]));
    } else if ((m = technique.match(/^deal with increment (-?\d+)$/))) {
      this.dealWithIncrement(Number(m[1]));
    } else {
      throw new Error(`unknown technique "${technique}"`);
    }
  }
}
module.exports = CardOfInterest;
