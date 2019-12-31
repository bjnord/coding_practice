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
     * number of cards in the deck
     * @member {number}
     */
    this.nCards = nCards;  // kept for better performance
    // private: deck storage
    this._cards = [...Array(nCards).keys()];  // starts in "factory order"
    // private: position of interest
    this._cardPos = cardPos;
  }
  /**
   * the card at the position of interest
   * @member {Array}
   */
  get card()
  {
    return this._cards[this._cardPos];
  }
  /**
   * Deal cards into a new stack, reversing their order.
   */
  dealIntoNewStack()
  {
    this._cards = this._cards.reduce((newCardOfInterest, card) => {
      newCardOfInterest.unshift(card);
      return newCardOfInterest;
    }, []);
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
    if (n === 0) {
      return;
    } else if (n > 0) {
      const cutCards = this._cards.splice(0, n);
      this._cards = this._cards.concat(cutCards);
    } else {  // (n < 0)
      const cutCards = this._cards.splice(n, -n);
      this._cards = cutCards.concat(this._cards);
    }
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
    const dealtCards = new Array(this.nCards).fill(null);
    for (let i = 0, m = 0; i < this.nCards; i++) {
      dealtCards[m] = this._cards[i];
      // faster than modulo operator:
      if ((m += n) >= this.nCards) {
        m -= this.nCards;
      }
    }
    this._cards = dealtCards;
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
    while (repeat-- > 0) {
      this.doTechniques(techniques);
    }
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
