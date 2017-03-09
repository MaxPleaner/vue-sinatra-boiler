require './server.rb'

# ------------------------------------------------
# Passes requests through to the webpack server on port 8080
# Requests to /api are excluded from this, and are handled by Sinatra.
#
# Code taken from
# https://gist.github.com/timothypage/cc80e8f8db1b0b7eb0c81e8317a536ec
# ------------------------------------------------

require 'rack-proxy'
class AppProxy < Rack::Proxy
  def rewrite_env(env)
    env["HTTP_HOST"] = "localhost:8080"
    env
  end
end
run Rack::URLMap.new(
  '/api' => Server,
  '/' => AppProxy.new
)

# Note this file should not be run with "rackup"
# Instead, use "thin start"
