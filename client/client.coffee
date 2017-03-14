module.exports = class Client

# ------------------------------------------------
# Setup and private vars
# ------------------------------------------------

  prod_base_url = "vue-sinatra-boiler-demo.herokuapp.com"
  dev_base_url = "localhost:3000"

  base_url = if process.env.NODE_ENV == "production" 
    "https://#{prod_base_url}"
  else
    "http://#{dev_base_url}"

  ws_base_url = if process.env.NODE_ENV == "production"
    "wss://#{prod_base_url}"
  else
    "ws://#{dev_base_url}"


# ------------------------------------------------
# The exported object
# ------------------------------------------------

  base_url: base_url

  ws_base_url: ws_base_url

  constructor: ({deps}) ->
    {
      @Cookies, @components, @root_constructor,
      @Router, @Store, @$, @CrudMapper
    } = deps
    @root = @root_constructor.activate({ @Router, @components })
    @anchor = @$("#vue-anchor")[0]

  init: ->
    @attach_vue_to_dom()
    @init_ws_and_auth()
    @attach_stylesheet_to_dom()
  
  attach_vue_to_dom: ->
    @root.$mount @anchor
    
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
     @$.get "#{@base_url}/token", (response) ->
      { token } = JSON.parse response
      callback({ token })

  init_websockets: ({token}) =>
    @Cookies.set("token", token)
    @Store.commit("SET_TOKEN", token)
    @ws = new WebSocket "#{@ws_base_url}/ws?token=#{token}"
    @ws.onopen = @ws_onopen
    @ws.onmessage = @ws_onmessage
    @ws.onclose = @ws_onclose

  ws_onopen: =>
    @CrudMapper.get_indexes()
    @ws_connect_interval && clearInterval(@ws_connect_interval)
    if @token_was_in_cookie
      @try_authenticate(token: @Store.state.token)
  
  ws_onmessage: (message) =>
    data = JSON.parse(message.data)
    if data.action == 'logged_in'
      { username, new_token } = data
      @login { username, new_token }
    else
      @CrudMapper.process_ws_message(data)

  ws_onclose: (e) =>
    # The close event only logs out if there's a special message passed from
    # the server. Otherwise it's assumed to be a temporary disconnection
    # and the client will try and reconnect on an interval.
    if e.reason == "logged_out"
      @Cookies.expire("token")
      @Store.commit("SET_TOKEN", null)

    @Store.commit("SET_USERNAME", null)
    @Store.commit("SET_LOGGED_IN", false)
    @ws_connect_interval ||= setInterval =>
      @init_ws_and_auth()
    , 500

  try_authenticate: ({token}) ->
    @ws.send JSON.stringify
      action: "try_authenticate"
      token: token

  login: ({username, new_token}) =>
    @Cookies.set("token", new_token)
    @Store.commit("SET_TOKEN", new_token)
    @Store.commit("SET_LOGGED_IN", true)
    @Store.commit("SET_USERNAME", username)

  logout: =>
    @$.get "#{@base_url}/logout?token=#{@Store.state.token}", (response) =>
      { success, error } = JSON.parse response
      if error
        alert(error)
      # The success case isn't handled here - it's handled in "onclose" on the websocket

  logout_all_devices: =>
    @$.get "#{@base_url}/logout_all_devices?token=#{@current_token}", (response) =>
      { success, error } = JSON.parse response
      if error
        alert(error)
      # The success case isn't handled here - it's handled in "onclose" on the websocket
