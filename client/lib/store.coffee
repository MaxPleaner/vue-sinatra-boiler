module.exports =
  load: ({deps}) ->
    { Vue, Vuex } = deps 
    Vue.use Vuex
    new Vuex.Store
      strict: process.env.NODE_ENV isnt 'production'
      state: require('./store/state').load({deps})
      mutations: require('./store/mutations').load({deps})
      actions: require('./store/actions').load({deps})

    
