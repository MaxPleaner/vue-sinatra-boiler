module.exports = load: ({deps: {Vue, mapState}}) ->
  Vue.component "notices",
    template: require('html-loader!./notices.slim')
    computed: mapState(['notices', 'errors'])
