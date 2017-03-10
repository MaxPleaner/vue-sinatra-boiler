class Ws

  # Opens a new websocket connection from a request
  def self.run(request)
    return unless Faye::WebSocket.websocket?(request.env)
    socket = Faye::WebSocket.new(request.env)
    socket.onopen = Proc.new { |e| onopen(request, socket) }
    socket.onmessage = Proc.new { |e| onmessage(request, socket, e.data) }
    socket.onclose = Proc.new { |e| onclose(request, socket) }
    socket.rack_response
  end

  def self.onopen(request, ws)
    token = request.params["token"]
    if token
      Sockets[token] = ws
    else
      ws.close
    end
  end

  def self.onmessage(request, ws, msg_data)
    data = JSON.parse msg_data
    if data["action"] == "try_authenticate"
      try_authenticate(ws, data["token"])
    end
  end

  def self.onclose(request, ws)
    delete_socket(request, ws)
  end

  class << self

    private

    def try_authenticate(ws, token)
      if username = AuthenticatedTokens[token]
        ws.send({
          action: "logged_in",
          username: username  
        }.to_json)
      end
    end

    def send_json_message(ws, msg)
      EM.next_tick { ws.send msg.to_json }
    end

    def delete_socket(request, ws)
      token = CGI.parse(URI.parse(ws.url).to_s)["token"]
      Sockets.delete token
    end

  end

end
