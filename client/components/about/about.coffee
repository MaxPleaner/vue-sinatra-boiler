module.exports = load: ({deps: {Vue}}) ->
  Vue.component "about",
    template: require('html-loader!./about.slim')
