const mass2fuel = (mass) => {
  return Math.floor(mass / 3.0) - 2;
};
const mass2fullfuel = (mass) => {
  var total = 0;
  for (var fuel = mass2fuel(mass); fuel > 0; ) {
    total += fuel;
    fuel = mass2fuel(fuel);
  }
  return total;
};
exports.mass2fuel = mass2fuel;
exports.mass2fullfuel = mass2fullfuel;
