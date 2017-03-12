# ------------------------------------------------
# deps
# ------------------------------------------------

import Vue from 'vue'
import VueRouter from 'vue-router'
import Vuex from 'vuex'
mapState = Vuex.mapState
mapActions = Vuex.mapActions
$ = require 'jquery'
Cookies = require('cookies-js')
deps = { Vue, $, Vuex, mapState, mapActions, VueRouter, Cookies }

# ------------------------------------------------
# local files - the ordering should be preserved
# ------------------------------------------------

Object.assign deps,
  CrudMapper: require("./lib/crud_mapper").load { deps }
Object.assign deps,
  Store: require('./lib/store').load { deps }
Object.assign deps,
  components: require('./components/components').load { deps }
Object.assign deps,
  root_constructor: require('./components/root/root').load { deps }  
Object.assign deps,
  Router: require('./lib/router').load { deps } 

# ------------------------------------------------
# Start client side app
# ------------------------------------------------

Client = require "./client"

$ ->
  window.AppClient = new Client({deps})
  AppClient.init()
