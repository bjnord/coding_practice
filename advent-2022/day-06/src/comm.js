'use strict';
/** @module comm */

exports.firstPacketMarker = (data) => {
  for (let i = 0; i <= data.length - 4; i++) {
    let match = true;
    for (let j = 0; j < 4; j++) {
      for (let k = 0; k < j; k++) {
        if (data.charAt(i + j) == data.charAt(i + k)) {
          match = false;
          break;
        }
      }
      if (!match) {
        break;
      }
    }
    if (match) {
      return i + 4;
    }
  }
  return null;
};

exports.firstMessageMarker = (data) => {
  for (let i = 0; i <= data.length - 14; i++) {
    let match = true;
    for (let j = 0; j < 14; j++) {
      for (let k = 0; k < j; k++) {
        if (data.charAt(i + j) == data.charAt(i + k)) {
          match = false;
          break;
        }
      }
      if (!match) {
        break;
      }
    }
    if (match) {
      return i + 14;
    }
  }
  return null;
};
