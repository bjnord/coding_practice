module.exports = function () {
  this.mass2fuel = function (mass) {
    return Math.floor(mass / 3.0) - 2;
  };
  this.mass2fullfuel = function (mass) {
    var total = 0;
    for (var fuel = this.mass2fuel(mass); fuel > 0; ) {
      total += fuel;
      fuel = this.mass2fuel(fuel);
    }
    return total;
  };
};
