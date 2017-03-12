module.exports = class Client

  constructor: ({deps}) ->
    { @Cookies, @components, @root_constructor, @Router, @Store, @$ } = deps
    @root = @root_constructor.activate({ @Router, @components })
    @auth = new @components.authenticator()
    @anchor = @$("#vue-anchor")[0]

  init: ->
    @root.$mount @anchor
    @init_ws_and_auth()
    @attach_stylesheet_to_dom()
  
  attach_stylesheet_to_dom: ->
    require("./style/app.sass")

  init_ws_and_auth: ->
    @get_token().then @init_websockets

  get_token: -> new Promise (resolve, reject) =>
    token = @token_from_cookie()
    if token
      @token_was_in_cookie = true
      resolve({token})
    else
      @new_credentials_or_token_from_server(resolve)

  token_from_cookie: ->
    @Cookies.get "token"

  new_credentials_or_token_from_server: (callback) ->
     @$.get "http://localhost:3000/token", (response) ->
      { token } = JSON.parse response
      callback({ token })

  init_websockets: ({token}) =>
    @Cookies.set("token", token)
    @current_token = token
    @ws = new WebSocket "ws://localhost:3000/ws?token=#{token}"
    @ws.onopen = @ws_onopen
    @ws.onmessage = @ws_onmessage
    @ws.onclose = @ws_onclose

  ws_onopen: =>
    @ws_connect_interval && clearInterval(@ws_connect_interval)
    @auth.token = @current_token
    if @token_was_in_cookie
      @try_authenticate(token: @current_token)
  
  ws_onmessage: (message) =>
    data = JSON.parse(message.data)
    if data.action == 'logged_in'
      { username, new_token } = data
      @login { username, new_token }
    else if data.msg
      console.log data.msg

  ws_onclose: (e) =>
    if e.reason == "logged_out"
      @Cookies.expire("token")
      @current_token = null

    @auth.username = null
    @auth.done = false
    @ws_connect_interval ||= setInterval =>
      @init_ws_and_auth()
    , 500

  try_authenticate: ({token}) ->
    @ws.send JSON.stringify
      action: "try_authenticate"
      token: token

  login: ({username, new_token}) =>
    console.log("new token: #{new_token}")
    @Cookies.set("token", new_token)
    @current_token = new_token
    @auth.done = true
    @auth.username = username

  logout: =>
    @$.get "http://localhost:3000/logout?token=#{@current_token}", (response) =>
      { success, error } = JSON.parse response
      if error
        alert(error)
      # The success case isn't handled here - it's handled in "onclose" on the websocket

  logout_all_devices: =>
    @$.get "http://localhost:3000/logout_all_devices?token=#{@current_token}", (response) =>
      { success, error } = JSON.parse response
      if error
        alert(error)
      # The success case isn't handled here - it's handled in "onclose" on the websocket
