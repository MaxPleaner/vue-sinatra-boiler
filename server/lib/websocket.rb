class Websocket

  # A wrapper over an underlying websocket API
  # If ever the websocket server dependency would need to change,
  # this file would be a place to swap out libraries.
  #
  # With each handler (open, close, message) is passed the request object
  # in addition to the websocket connection object and any additional arguments
  # (such as message)
  #
  # If this is being initialized, the request is assumed to be of the
  # websocket variety.
  #
  # Operations in this class are implemented in a stack which needs to be
  # finalized by #ready.
  #
  # for example:
  #   socket = Websocket.new(request)
  #   socket.onopen { |req, socket| }
  #   socket.onclose { |req, socket| }
  #   socket.onmessage { |req, socket, msg| }
  #   socket.ready
  #
  def initialize(req)
    @req = req
    @socket = Faye::WebSocket.new(req.env)
    @stack = {}
  end

  def onopen &blk
    @stack[:onopen] = blk
  end

  def onclose &blk
    @stack[:onclose] = blk
  end

  def onmessage &blk
    @stack[:onmessage] = blk
  end

  def ready
    @socket.on(:open) { @stack[:onopen].call @req, @socket }
    @socket.on(:close) { @stack[:onclose].call @req, @socket }
    @socket.on(:message) { |msg| @stack[:onmessage].call @req, @socket, msg }
    @socket.rack_response
  end
end
