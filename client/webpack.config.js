// Little hack so that that coffee-loader uses coffee 2
var coffeescript = require('coffee-script')
require.cache[require.resolve('coffee-script')] = require.cache[require.resolve('coffeescript')]

module.exports = {

  entry: "./loader.coffee",

  // the bundle is stored in memory, though it's referenced by this path
  output: {
    filename: "bundle.js"
  },

  // Outline of loaders:
  //
  //   slim => html => coffee
  //     see components/root/root.coffee for an example of loading a slim
  //     template into a coffee string as HTML
  //
  //   coffee => js
  //      everything is concatenated into bundle.js
  //
  //   sass => css
  //      What's not intuitive about this is that the sass file
  //      actually has to be required from javascript.
  //      This triggers it to be attached to the DOM automatically.
  //      See client.coffee, which loads style/app.sass
  //  

  module: {
    loaders: [
      {test: /\.slim$/, loader: ['slim-lang-loader']},
      {test: /\.coffee$/, loader: 'coffee-loader'},
      { test: /\.sass$/, loader: "style-loader!css-loader!sass-loader" }
    ]
  },

  resolve: {
    extensions: [".js", ".coffee", ".slim", ".sass", ".css"],
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },

  // Starts a static server with index.html at root 
  context: __dirname,

};
