class Routes::Ws

  # This method is called from the Sinatra route handler
  def self.run(request)
    return unless Faye::WebSocket.websocket?(request.env)
    socket = Websocket.new request
    socket.onopen &method(:onopen)
    socket.onmessage &method(:onmessage)
    socket.onclose &method(:onclose)
    socket.ready
  end

  # Handler for newly opened websocket
  # Pushes the websocket connection object into the global Sockets hash
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

  # Handler for received message from websocket
  # Sends a message to all clients echoing what was received
  def self.onmessage(request, ws, msg)
    ws.send({
      msg: (JSON.parse(msg.data)["msg"])
    }.to_json)
  end

  # Handler for closed websocket event
  # Deletes the websocket connection object from the global Sockets hash
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
