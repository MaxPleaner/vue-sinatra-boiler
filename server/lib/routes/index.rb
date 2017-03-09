class Routes::Index

  Gemmy.patches.each { |patch| using patch }
  # This method is called from the Sinatra route handler
  def self.run(request)
    is_websocket = websocket_request? request
    m(is_websocket ? :websocket_request : :http_request).call request
  end

  # Check if the request is of the websocket variety
  def self.websocket_request?(request)
    Faye::WebSocket.websocket? request.env
  end

  # Handle HTTP requests
  # IMPORTANT:
  #   the session object here is persistent across client reloads,
  #   unlike the one available in the websocket connection.
  #
  def self.http_request request
    { token: request.session["session_id"] }.to_json 
  end

  # Handle websocket requests
  #   Do not attempt to use request.session here; it is not persistent
  #   This request object should already have a "token" param set
  def self.websocket_request request
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
    if Sockets[token]
      socket_already_connected(request, ws)
    else
      Sockets[token] = ws
    end
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

    def socket_already_connected(request, ws)
      # TODO this is not what should happen
      ws.send({
        msg: <<-TXT
          this application doesn't support logging in on multiple devices.
          Logging you out everywhere.
          Try logging in again now
        TXT
      }.to_json)
      delete_socket(request, ws)
    end

    def delete_socket(request, ws)
      token = CGI.parse(URI.parse(ws.url).to_s)["token"]
      Sockets.delete token
    end

  end

end
