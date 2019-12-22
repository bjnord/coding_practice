'use strict';

class Deck
{
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
  dealIntoNewStack()
  {
    this.cards = this.cards.reduce((newDeck, card) => {
      newDeck.unshift(card);
      return newDeck;
    }, []);
  }
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
  dealWithIncrement(n)
  {
    if (n < 1) {
      throw new Error('invalid increment');
    }
    const dealtCards = new Array(this.nCards).fill(null);
    for (let i = 0, m = 0; i < this.nCards; i++) {
      dealtCards[m] = this.cards[i];
      // faster than modulo operator:
      if ((m += n) >= this.nCards) {
        m -= this.nCards;
      }
    }
    this.cards = dealtCards;
  }
  doTechniques(techniques)
  {
    techniques.trim().split(/\n/).forEach((t) => this.doTechnique(t));
  }
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
