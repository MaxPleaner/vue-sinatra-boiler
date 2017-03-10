class Routes::Ws

  def self.run(request)
    return unless Faye::WebSocket.websocket?(request.env)
    socket = Faye::WebSocket.new(req.env)
    socket.onopen { onopen(request, socket) }
    socket.onmessage { |msg| onmessage(request, ws, msg) }
    socket.onclose { onclose(request, ws) }
    socket.rack_response
  end

  def self.onopen(request, ws)
    token = request.params["token"]
    unless token
      ws.send({
        msg: "no valid token was sent with websocket; invalid"
      }.to_json)
      ws.close
      return
    end
    Sockets[token] = ws
  end

  def self.onmessage(request, ws, msg)
  end

  def self.onclose(request, ws)
    delete_socket(request, ws)
  end

  class << self

    private

    def send_json_message(ws, msg)
      EM.next_tick { ws.send msg.to_json }
    end

    def delete_socket(request, ws)
      token = CGI.parse(URI.parse(ws.url).to_s)["token"]
      Sockets.delete token
    end

  end

end
