
# ================================================
# Client-side entrace to the app
# This has a lot of dependency imports which are
# passed around as arguments to the other files.
# ================================================

# This is a bit unintuitive, but the following require automatically
# attaches the CSS stylesheet to the DOM.
require("./style/app.sass")

# Deps from NPM
import Vue from 'vue'
import Vuex from 'vuex'
mapState = Vuex.mapState
$ = require 'jquery'
import VueRouter from 'vue-router'
deps = { Vue, $, Vuex, mapState, VueRouter }

# Custom deps which need to be added in order
Object.assign deps,
  Store: require('./lib/store').load { deps }
Object.assign deps,
  components: require('./components/components').load { deps }
Object.assign deps,
  Router: require('./lib/router').load { deps } 

# Define app class
class Client
  anchor: $("#vue-anchor")[0]
  components: deps.components
  load: ->
    @root = @components.root.activate({ Router: deps.Router })
    @root.$mount @anchor

# Start app
$ ->
  new Client().load()
