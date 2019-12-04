const passwordMatches = (password) => {
  if (password === undefined) {
    throw new Error('Invalid argument');
  }
  const increases = (pass) => {
    for (var i = 0; i < pass.length-1; i++) {
      if (pass[i] > pass[i+1]) {
        return false;
      }
    }
    return true;
  }
  const doubles = (pass) => {
    for (var i = 0; i < pass.length-1; i++) {
      if (pass[i] == pass[i+1]) {
        return true;
      }
    }
    return false;
  }
  return increases(password) && doubles(password);
};
exports.passwordMatches = passwordMatches;
