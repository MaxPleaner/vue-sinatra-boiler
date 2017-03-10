module.exports = load: ({deps: {Vue, mapState}}) ->
  Vue.component "todos",
    template: require('html-loader!./todos.slim')
