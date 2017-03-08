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
  def self.http_request request
    request.renderers.slim.call :index
  end

  # Handle websocket requests
  def self.websocket_request request
    socket = Websocket.new request
    socket.onopen &method(:onopen)
    socket.onmessage &method(:onmessage)
    socket.onclose &method(:onclose)
    socket.ready
  end

  # Handler for newly opened websocket
  # Pushes the websocket connection object into the global Sockets array
  def self.onopen(request, ws)
    Sockets << ws
  end

  # Handler for received message from websocket
  # Sends a message to all clients echoing what was received
  def self.onmessage(request, ws, msg)
    EM.next_tick { Sockets.each{|s| s.send "got #{msg.data}" } }
  end

  # Handler for closed websocket event
  # Deletes the websocket connection object from the global Sockets array
  def self.onclose(request, ws)
    warn("websocket closed")
    Sockets.delete(ws)
  end

end
