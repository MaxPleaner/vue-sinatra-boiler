# ================================================
# Entry to the Sinatra server
# ------------------------------------------------
# This file should not be run directly
# Run it with "thin start"
# ================================================

require 'sinatra/base'
require 'faye/websocket'
require 'byebug'
require 'sinatra_auth_github'
require('dotenv'); Dotenv.load
require 'sinatra/cross_origin'

# Requires all ruby files in this directory.
# Orders them by the count of "/" in their filename.
# Therefore, shallower files are loaded first.
# The reasoning for this is to support the common convention of naming
# files according to their contained class hierarchies.
# i.e. class Foo would be in foo.rb,
#      class Foo::Bar would be in foo/bar.rb,
#
# If there is the situation where a class depends on another that is in a 
# deeper-nested file, there's always the option to pass the dependency at
# runtime.

Dir.glob("./**/*.rb").sort_by { |x| x.count("/") }.each do |path|
  require path
end

# The REST routes (listed in this file) cannot store information in the session
# since it's on another host.
# Rather, they pass back and forth a token identifier
#
# This is the :token param, and is required on all routes except for
# /token
#
# Here's an outline of the flow:
#
# 1. Client hits GET /token, gets a new token
# 2. Client sends token with websocket connection request at GET /ws
# 3. Client hits GET /authenticate and goes through Github oAuth login
# 4. Github sends callback to server, which sends the OK to client over websocket

# In leue of sessions, three global objects are used:
#   Users: <Hash> with keys: <username> and vals: <Set(token)>
#   AuthenticatedTokens: <hash> with keys: <token> and vals: <username>
#   Sockets: <hash> with keys: <token> and vals: <socket>

Sockets = {}
AuthenticatedTokens = {}
Users = Hash.new { |hash, key| hash[key] = Set.new }

class Server < Sinatra::Base

  set :server, 'thin'
  Faye::WebSocket.load_adapter('thin')

  # Allow some routes to be accessed from different origins
  # This is unnecessary for websocket requests, since browsers don't implement
  # the same restictions.

  register Sinatra::CrossOrigin

  # Github oAuth setup
  # session is needed for the Github oAuth gem
  # but its not used elsewhere

  enable :sessions
  set :github_options, {
    scopes: "user",
    secret: ENV["GITHUB_CLIENT_SECRET"],
    client_id: ENV["GITHUB_CLIENT_ID"]
  }
  register Sinatra::Auth::Github
  
  # ------------------------------------------------
  # Standard HTTP routes
  # (get '/ws' is the entrance to the websocket API)
  # ------------------------------------------------

  # First clients request a token

  get '/token' do
    cross_origin allow_origin: "http://localhost:8080"
    { token: new_token }.to_json
  end

  # Then they send it in websocket connection request
  # See server/lib/routes/ws.rb

  get '/ws' do
    Routes::Ws.run(request)
  end

  # Then they authenticate with Github
  #
  # If the client refreshes the page after logging in, they should have stored
  # the token in a cookie. If they hit this route with the same token, it
  # keeps them logged in.
  #
  # This needs to be clicked like a regular link - no AJAX
  #
  # TODO render a proper HTML page after authenticating not just plaintext
  # saying they can close the window.

  get '/authenticate' do
    if token = params["token"]
      if socket = Sockets[token]
        unless username = AuthenticatedTokens[token]
          authenticate!
          username = get_username
          Users[username] << (token)
          AuthenticatedTokens[token] = username
        end
        socket.send({
          action: "logged_in",
          username: username
        }.to_json)
        "authenticated as #{username}. (this window can be closed)"
      else
        "error. lost your websocket connection (this window can be closed)"
      end
    else
      "error. That request requires a token (this window can be closed)"
    end
  end

  get '/logout' do
    token = params[:token]
    if token
      if username = AuthenticatedTokens[token]
        logout!
        Sockets[token].send({
          action: "logged_out"
        }.to_json)
      else
        if ws = Sockets[token]
          ws.send({msg: "can't find user to log out"}.to_json)
        else
          {error: "can't find user to log out"}.to_json
        end
      end
    else
      { error: 'cant log out; no token provided' }.to_json
    end
  end

  private

  def get_username
    github_user.login
  end

  def new_token
    SecureRandom.urlsafe_base64
  end

end
