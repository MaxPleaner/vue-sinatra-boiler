module.exports = load: ({deps: {Vue, mapState}}) ->

  Vue.component "authenticator",
    template: require('html-loader!./authenticator.slim')
    computed: Object.assign mapState(['token', 'username', 'logged_in']),
      authenticate_url: ->
        if !@token
          "#"
        else
          "http://localhost:3000/authenticate?token=#{@token}"        
    methods:
      open_in_new_tab: (e) ->
        e.preventDefault()
        popup = window.open "about:blank", "_blank"
        popup.location = e.currentTarget.href
      logout: -> AppClient.logout()
      logout_all_devices: -> AppClient.logout_all_devices()
