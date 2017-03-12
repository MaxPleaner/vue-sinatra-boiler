module.exports = load: ({deps: { Vue, Store }}) ->

  activate: ({Router, components}) ->
    new Vue(
      store: Store
      router: Router
      template: require('html-loader!./root.slim')
    )
