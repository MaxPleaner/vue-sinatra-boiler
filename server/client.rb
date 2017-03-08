require 'faye/websocket'
require 'eventmachine'
require 'byebug'
require 'gemmy'

if $start_client

  Settings = {awaiting_input: false }
  EM.run do

    EM.tick_loop do
    if !Settings[:awaiting_input]
      Thread.new do
        Settings[:awaiting_input] = true
        inp = gets.chomp
        Settings[:awaiting_input] = false
        Ws.send inp
      end
      sleep 0.2
    end
    end.on_stop { EM.stop }

    ServerWebsocketUrl = ENV["SERVER_WS_URL"] || 'ws://localhost:3000/'

    Ws = Faye::WebSocket::Client.new ServerWebsocketUrl

    Ws.on :message do |event|
      puts event.data
    end

  end

end