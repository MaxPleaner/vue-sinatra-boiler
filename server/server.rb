# auto create accessor methods for hash keys
require 'ostruct'

# The "modular" version of Sinatra (no global monkeypatch).
require 'sinatra/base'
 
# Eventmachine-based websocket server
require 'faye/websocket'

# My gem of Ruby language utils. This in turn requires activesupport,
# colored, awesome_print, etc.
# see http://rubygems.org/gems/gemmyrb
require 'gemmy'

# A debugger. Pry has more functionality but has become buggy itself.
require 'byebug'

# better than CSS
require 'sass'

# better than JS
require 'coffee_script'

# Requires all ruby files in this directory.
# Orders them by the count of "/" in their filename.
# Therefore, shallower files are loaded first.
# The reasoning for this is to encourage the common convention of naming
# files according to their contained class hierarchies.
# i.e. class Foo would be in foo.rb,
#      class Foo::Bar would be in foo/bar.rb,
Dir.glob("./**/*.rb").sort_by { |x| x.count("/") }.each do |path|
  require path
end

# A global array of sockets.
# This can certainly be altered to a hash if faster lookups are desired.
Sockets = []

# Our server, a Sinatra app
class Server < Sinatra::Base

  # Thin works well with Faye and Sinatra
  # However keep in mind that the server needs to be run with "thin start"
  # NOT ruby server.rb,
  #     rackup,
  #     rackup -E production
  #     etc.
  # These will not work.
  set :server, 'thin'
  Faye::WebSocket.load_adapter('thin')

  # The root route, which handles both websocket and HTTP requests
  # See server_skeleton/lib/routes/index.rb
  get '/' do
    Routes::Index.run(request_obj)
  end

  # The 'request' variable is passed along to route handlers
  # Some extra information is attached to make for a simpler API
  def request_obj
    if !defined?(request.renderers)
      _renderers = method(:renderers)
      request.define_singleton_method(:renderers) { _renderers.call }
    end
    request
  end

  # For now, the only extra information being sent in 'request'
  # is the method 'slim', which would otherwise be unavailable in
  # the scope of a different class.
  def renderers
    OpenStruct.new(
      slim: method(:slim)
    )
  end

end

# This file should not be run directly
# Run it with "thin start"