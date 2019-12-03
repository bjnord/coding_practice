module.exports = function () {
  this.mass2fuel = function (mass) {
    return Math.floor(mass / 3.0) - 2;
  };
};
