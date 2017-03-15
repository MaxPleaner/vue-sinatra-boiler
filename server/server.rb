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

Users = Hash.new { |hash, key| hash[key] = Set.new }
AuthenticatedTokens = {}
Sockets = Hash.new { |hash, key| hash[key] = Set.new }

CLIENT_BASE_URL = if ENV["RACK_ENV"] == "production"
  "https://maxpleaner.github.io"
else
  "http://localhost:8080"
end

class Server < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  if ENV["RACK_ENV"] == "production"
    configure :production do
     db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')
     ActiveRecord::Base.establish_connection(
       :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
       :host     => db.host,
       :username => db.user,
       :password => db.password,
       :database => db.path[1..-1],
       :encoding => 'utf8'
     )
    end
  else
    set :database, {adapter: "sqlite3", database: "db.sqlite3"}
    set :show_exceptions, true
  end

  set :server, 'thin'
  Faye::WebSocket.load_adapter('thin')

  register Sinatra::CrossOrigin

  enable :sessions
  set :github_options, {
    scopes: "user",
    secret: ENV["GITHUB_CLIENT_SECRET"],
    client_id: ENV["GITHUB_CLIENT_ID"]
  }
  register Sinatra::Auth::Github
  

  logged_in_only = Proc.new do |request|
    if AuthenticatedTokens[request.params['token']]
      false
    else
      { error: ["not_authenticated for #{request.request_method} #{request.path_info}"] }.to_json
    end
  end

  register Sinatra::CrudGenerator
  crud_generate(
    resource: "todo",
    resource_class: Todo,
    cross_origin_opts: {
      allow_origin: CLIENT_BASE_URL
    },
    create: { auth: logged_in_only },
    update: { auth: logged_in_only },
    destroy: { auth: logged_in_only }
  )

  get '/token' do
    cross_origin allow_origin: CLIENT_BASE_URL
    { token: new_token }.to_json
  end

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

        new_token = SecureRandom.urlsafe_base64
        Sockets[new_token] = Sockets.delete(token)
        AuthenticatedTokens[new_token] = AuthenticatedTokens.delete(token)
        Users[username] << new_token

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

  get '/logout' do
    cross_origin allow_origin: CLIENT_BASE_URL
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
        { error: ["can't find user to log out"] }.to_json
      end
    else
      { error: ['cant log out; no token provided'] }.to_json
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
