module.exports = load: ({deps: {Vue}}) ->
  Vue.component "contact",
    template: require('html-loader!./contact.slim')
