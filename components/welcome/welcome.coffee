module.exports = load: ({deps: {Vue}}) ->
  Vue.component "welcome",
    template: require('html-loader!./welcome.slim')
