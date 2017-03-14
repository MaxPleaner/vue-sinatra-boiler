# ================================================
# Entry to the Sinatra server
# ------------------------------------------------
# This file should not be run directly
# Run it with "thin start"
# ================================================

require 'sinatra/base'
require "sinatra/activerecord"
require 'faye/websocket'
require 'byebug'
require 'sinatra_auth_github'
require('dotenv'); Dotenv.load
require 'sinatra/cross_origin'
require 'active_support/all'

require './crud_generator'
require './server_push'
require './models'
require './ws'

# The REST routes (listed in this file) cannot store information in the session
# since it's on another host.
# Rather, they pass back and forth a token identifier
#
# This is the :token param, and is required on all routes except for
# /token
#
# Here's an outline of the login flow:
#
# 1. Client hits GET /token, gets a new token and stores in 1st party cookie (not accessible from server)
# 2. Client sends token as query param with websocket connection request at GET /ws
# 3. Client hits GET /authenticate and goes through Github oAuth login
#    - if a token was already in their cookie they attempt to alidaa
# 4. Github sends callback to server, which sends a new authenticated token to client over websocket via the "logged_in" message
# 5. If client refreshes page and token is in cookie, steps 3-4 happen automatically. Otherwise step 3 is triggered by a button.
#
# Note that since clients might have multiple tabs open, they continually listen for the ws "logged_in" event
# and use it to update their in-memory token. For example, if a second tab is opened then the login flow will trigger
# the new tab's socket to be authenticated and a new token generated. The first tab's in-memory token is now invalid, but since
# it's listening for "logged_in" it will be able to receive the new token.
#
# The logout flow accounts for the possibility that the client has multiple tabs open.
# Each tab would share a token since it's stored in a client-side cookie, but they would have unique socket objects.
# When a 
#
# 1. Client hits GET /logout
# 2. Server closes all ws connections for that token and sends a specific exit code (4567) to indicate
#    actual logout versus temporary disconnection
# 3. Client checks for this exit code in the onclose handler, clears cookie and inits login flow
#
# In leue of sessions, four global objects are used:
#   Users: <Hash> with keys: <username> and vals: <Set(token)>
#   AuthenticatedTokens: <hash> with keys: <token> and vals: <username>
#   Sockets: <hash> with keys: <token> and vals: <Set(socket)>

Users = Hash.new { |hash, key| hash[key] = Set.new }
AuthenticatedTokens = {}
Sockets = Hash.new { |hash, key| hash[key] = Set.new }

class Server < Sinatra::Base

  register Sinatra::ActiveRecordExtension
  set :database, {adapter: "sqlite3", database: "foo.sqlite3"}
  set :server, 'thin'
  Faye::WebSocket.load_adapter('thin')

  # Allow some routes to be accessed from different origins.
  # This is unnecessary for websocket requests, since browsers don't implement
  # the same restictions.

  register Sinatra::CrossOrigin

  # Github oAuth setup
  # session is needed for the Github oAuth gem, but its not used elsewhere

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

  register Sinatra::CrudGenerator
  crud_generate(
    resource: "todo",
    resource_class: Todo,
    cross_origin_opts: {
      allow_origin: "http://localhost:8080"
    },
  )

  get '/token' do
    cross_origin allow_origin: "http://localhost:8080"
    { token: new_token }.to_json
  end

  # See ws.rb
  get '/ws' do
    Ws.run(request)
  end

  # TODO render a proper HTML page after authenticating not just plaintext
  # saying they can close the window.
  get '/authenticate' do
    username = nil
    token = params["token"]
    if token
      sockets = Sockets[token]
      if sockets.any?
        username = AuthenticatedTokens[token]
        unless username
          authenticate!
          username = get_username
          AuthenticatedTokens[token] = username
        end
        # Refresh the token
        new_token = SecureRandom.urlsafe_base64
        Sockets[new_token] = Sockets.delete(token)
        AuthenticatedTokens[new_token] = AuthenticatedTokens.delete(token)
        Users[username] << new_token
        # Send the new token which is authenticated
        sockets.each do |socket|
          socket.send({
            action: "logged_in",
            username: username,
            new_token: new_token
          }.to_json)
        end
        "authenticated as #{username}. (this window can be closed)"
      else
        "error. lost your websocket connection (this window can be closed)"
      end
    else
      "error. That request requires a token (this window can be closed)"
    end
  end

  # Disable all of a users tokens
  get '/logout_all_devices' do
    cross_origin allow_origin: "http://localhost:8080"
    token = params[:token]
    if token
      if username = AuthenticatedTokens[token]
        logout!
        tokens = Users[username]
        tokens.each do |user_token|
          AuthenticatedTokens.delete user_token
          Sockets[user_token].each { |ws| ws.close(401, "logged out") }
          Sockets.delete user_token
        end
        Users[username].clear
        { success: "logged out" }.to_json
      else
        { error: "can't find user to log out" }.to_json
      end
    else
      { error: 'cant log out; no token provided' }.to_json
    end
  end

  # This is hit over AJAX
  # This closes the websocket connection
  # Logs out all tabs sharing a token (which is almost certainly all their tabs)
  get '/logout' do
    cross_origin allow_origin: "http://localhost:8080"
    token = params[:token]
    if token
      if username = AuthenticatedTokens[token]
        logout!
        AuthenticatedTokens.delete token
        Users[username].delete token
        Sockets[token].each { |ws| ws.close(1000, "logged_out") }
        Sockets.delete token
        { success: "logged out" }.to_json
      else
        { error: "can't find user to log out" }.to_json
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
