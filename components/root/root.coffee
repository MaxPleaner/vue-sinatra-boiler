# This is like the layout.
# It contains the router-view call which renders
# the per-route component.
#
# Don't copy-paste this as a boiler for a new component.
# Use any other component for that.
# This one is different - it's not actually a component. 

module.exports = load: ({deps: { Vue, Store, mapState }}) ->

  activate: ({Router}) ->
    new Vue(
      store: Store
      router: Router
      template: require('html-loader!./root.slim')
    )
