const path = require('path');

module.exports = {
  mode: 'production',
  entry: {
    app: './websrc/index.js',
    shared: '../shared/websrc/index.js',
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
};
