require 'socket'
require 'uri'
class WebSocketClient
    def initialize(*args)
      @host = args[0]
      @port = args[1]
      @path = args[2]
    end
    
    def connect()
      @socket = TCPSocket.open(@host, @port)
      handshake =   "GET #{@path} HTTP/1.1\r\n"+
                      "Host: #{Socket.gethostname}\r\n"+
                      "Connection: Upgrade\r\n"+
                      "Sec-WebSocket-Key2: 12998 5 Y3 1  .P00\r\n"+
                      "Sec-WebSocket-Protocol: sample\r\n"+
                      "Upgrade: WebSocket\r\n"+
                      "Sec-WebSocket-Key1: 4 @1  46546xW%0l 1 5\r\n"+
                      "Origin: http://#{Socket.gethostname}\r\n"+
                      "\r\n"+
                      "^n:ds[4U\r\n"
      @socket.print(handshake)
      response = @socket.gets # Read lines from the socket
      raise(RuntimeError, "Bad Response #{response}") unless response =~ /\AHTTP\/1.1 101 /n
    end

    def socket
      @socket
    end
end


begin
  if(ARGV.length != 2)
    p "usage: web_socket_client [ws_local] [ws_numbers]"
    exit
  end
  
  ws_path = ARGV[0]
  clients_num = ARGV[1]

  uri = URI.parse ws_path

  sockets_array = Array.new
  clients_num.to_i.times do
    socket = WebSocketClient.new(uri.host, uri.port, uri.path)
    socket.connect
    sockets_array.push socket.socket
  end

  while true
    array = select(sockets_array, nil, nil, 1)
    next if array.nil?
    array[0].each do |socket|
      p socket.read_nonblock(100)
    end
  end
rescue
  p $!
end
