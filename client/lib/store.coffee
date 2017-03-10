
# Vuex is a centralized state management system.
# It's so the data is organized in one single location
# as opposed to being spread out through many components.
#
# An ideal system (which follows the "Flux" design pattern) has the store
# containing all of the application state. Components bind their properties
# to the store to get reactive state. This boiler doesn't quite
# achieve that paradigm but still tries to show how the pieces fit together
#
# The store is added to the root component and becomes available to
# all child components as a result.
#
# Vuex works a lot like Redux.
#
#   - "state" is the data itself
#      It's available as this.$store.state in components
#                       (aka @$store.state)
#
#   - "mutations" are atomic, synchronous manipulators of state
#      They're only called from actions.
#      They're automatically passed the state as an argument
#
#   - "actions" are wrappers over mutations and can be async.
#      They are callable from any component as top-level methods.
#      They're automatically passed a mutation dispatcher as an argument
#
#   - "getters" are used to read the state.
#      They're also available to any components.
#      They're automatically passed the state as an argument.

module.exports =
  load: ({deps: {Vue, Vuex}}) ->
    Vue.use Vuex
    new Vuex.Store
      strict: process.env.NODE_ENV isnt 'production'
      state: require('./store/state').load({deps})
      mutations: require('./store/mutations').load({deps})
      actions: require('./store/actions').load({deps})
      getters: require('./store/getters').load({deps})

    
