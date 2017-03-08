// Little hack so that that coffee-loader uses coffeescript 2
var coffeescript = require('coffee-script')
require.cache[require.resolve('coffee-script')] = require.cache[require.resolve('blackcoffee')]

module.exports = {
  entry: "./boiler_app.coffee",
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
    extensions: [".js", ".coffee", ".slim"],
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },
  context: __dirname
};
