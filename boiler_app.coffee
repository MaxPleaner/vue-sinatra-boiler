import Vue from 'vue'
$ = require 'jquery'
deps = { Vue, $ }

# ------------------------------------------------
# Nice class for my app
# ------------------------------------------------

class BoilerApp

  anchor: $("#vue-anchor")[0]
  components: require('./components/components').load {deps}   

  init: ->
    window.root = @components.root
    @components.root.$mount @anchor

# ------------------------------------------------
# Fine I'll consume it myself
# ------------------------------------------------

$ ->
  new BoilerApp().init()
