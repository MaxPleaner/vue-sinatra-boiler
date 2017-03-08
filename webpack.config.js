
// # ================================================
//   Webpack is a highly-capable static server
//   It tracks dependencies using 'require'
//   And does on-the-fly compilation / hot reloads
//
//   It's used here to serve the root index.html file
//   and to keep the bundle.js up to date.
// # ================================================

// Little hack so that that coffee-loader uses coffee 2
// coffee 2 can be replaced here with blackcoffee (another alternate interpreter)

var coffeescript = require('coffee-script')
require.cache[require.resolve('coffee-script')] = require.cache[require.resolve('coffeescript')]

module.exports = {

  // client side entrance to code

  entry: "./client.coffee",

  // the bundle is stored in memory, though it's referenced by this path

  output: {
    filename: "bundle.js"
  },

  // .slim requests are transformed to return html strings 
  // this is done with require and html-loader
  // see components/root/root.coffee for an example

  // Furthermore, coffeescript files are compiled to js

  module: {
    loaders: [
      {test: /\.slim$/, loader: ['slim-lang-loader']},
      {test: /\.coffee$/, loader: 'coffee-loader'},
      { test: /\.sass$/, loader: "style-loader!css-loader!sass-loader" }
    ]
  },

  // Vue is aliased in order to load the compiler
  // by default only the runtime is loaded.
  // This can all be done on the client though.

  resolve: {
    extensions: [".js", ".coffee", ".slim", ".sass", ".css"],
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },

  // Starts a static server with index.html at root 

  context: __dirname,

  plugins: [
  ]

};
