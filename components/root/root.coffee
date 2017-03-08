module.exports = load: ({deps: {Vue}}) ->
  new Vue
    template: require('html-loader!./root.slim')
