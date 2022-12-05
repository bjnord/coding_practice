'use strict';
class EmptyStackError extends Error {
  constructor(message) {
    super(message);
    this.name = 'EmptyStackError';
  }
};
module.exports = EmptyStackError;
