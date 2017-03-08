module.exports =
  load: ({deps: {Vue, Vuex}}) ->
    Vue.use Vuex
    new Vuex.Store
      strict: process.env.NODE_ENV isnt 'production'
      state:
        foo: 0
      mutations: {}

    
