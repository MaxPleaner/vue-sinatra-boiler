class Ws

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
      Sockets[token] << ws
    else
      ws.close
    end
  end

  def self.onmessage(request, ws, msg_data)
    data = JSON.parse msg_data
    token = data["token"]
    user = find_username(token)
    case data["action"]
    when "try_authenticate" then try_authenticate(ws, token)
    end
  end

  def self.onclose(request, ws)
    token = CGI.parse(URI.parse(ws.url).to_s)["token"]
    Sockets.delete token
  end

  class << self

    private

    def find_username(token)
      AuthenticatedTokens[token]
    end

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

  end

end
