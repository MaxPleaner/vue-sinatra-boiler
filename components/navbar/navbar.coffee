module.exports = load: ({deps: {Vue}}) ->
  Vue.component "navbar",
    template: require('html-loader!./navbar.slim')
