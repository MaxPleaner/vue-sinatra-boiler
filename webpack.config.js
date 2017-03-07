// Little hack so that that coffee-loader uses coffeescript 2
var coffeescript = require('coffee-script')
require.cache[require.resolve('coffee-script')] = require.cache[require.resolve('coffeescript')]

module.exports = {
  entry: "./main.coffee",
  output: {
    filename: "bundle.js"
  },
  module: {
    loaders: [
      {test: /\.slim$/, loader: ['slim-lang-loader']},
      {test: /\.coffee$/, loader: 'coffee-loader'}
    ]
  },
  resolve: {
    extensions: [".js", ".coffee", ".slim"]
  },
  context: __dirname
};
