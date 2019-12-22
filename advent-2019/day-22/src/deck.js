'use strict';

class Deck
{
  /**
   * Create a new deck of N cards, in "factory order".
   *
   * "Positions within the deck count from 0 at the top, then 1 for the card
   * immediately below the top card, and so on to the bottom. (That is,
   * cards start in the position matching their number.)" The latter is what
   * defines "factory order".
   *
   * @param {number} nCards - number of cards in the deck
   *
   * @return {Deck}
   *   Returns a new Deck class object.
   */
  constructor(nCards)
  {
    if (nCards < 2) {
      throw new Error('invalid number of cards');
    }
    // private: number of cards in deck
    this.nCards = nCards;  // kept for better performance
    /**
     * our deck
     * @member {Array}
     */
    this.cards = [...Array(nCards).keys()];  // starts in "factory order"
  }
  /**
   * Retrieve a card at the given position.
   *
   * @param {number} pos - position of card to retrieve
   *
   * @return {number}
   *   Returns the card at the given position.
   */
  cardAt(n)
  {
    return this.cards[n];
  }
  /**
   * Deal cards into a new stack, reversing their order.
   */
  dealIntoNewStack()
  {
    this.cards = this.cards.reduce((newDeck, card) => {
      newDeck.unshift(card);
      return newDeck;
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
      const cutCards = this.cards.splice(0, n);
      this.cards = this.cards.concat(cutCards);
    } else {  // (n < 0)
      const cutCards = this.cards.splice(n, -n);
      this.cards = cutCards.concat(this.cards);
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
      dealtCards[m] = this.cardAt(i);
      // faster than modulo operator:
      if ((m += n) >= this.nCards) {
        m -= this.nCards;
      }
    }
    this.cards = dealtCards;
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
module.exports = Deck;
