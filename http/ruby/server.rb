# Provide TCPServer and TCPSocket classes
require "socket"
require "byebug"
require_relative "app"

# initialize TCP server object that will listen for connections on port 2000
server = TCPServer.new("localhost", 2000)

# loop infinitely, processing one incoming connection at a time
loop do
  # wait until a client connects and then return a TCPSocket client object
  # can be used in similar fashion to other Ruby I/O objects
  socket = server.accept

  # read first line of request (the Request-Line of "method url version")
  # GET /path?foo=bar HTTP/1.1
  request_line = socket.gets
  method, path = request_line.split
  # query
  query = path.split("?").last
  # get data if any
  request_headers = []
  while (header = socket.gets) != "\r\n"
    request_headers.push(header)
  end
  # read data
  content_length_header = request_headers.find { |request_header| request_header =~ /Content-Length/ }
  if content_length_header
    content_length = content_length_header.scan(/\d/).first.to_i
    data = socket.read(content_length)
  end

  # log to STDERR for debugging
  STDERR.puts request_line

  # generate response by passing message to Rack app
  env = {
    "REQUEST_METHOD" => method,
    "PATH_INFO" => path,
    "QUERY_STRING" => query,
    "DATA" => data
  }
  # get response back from Rackapp
  response_line, headers, body = App.call(env)
  socket.print("#{response_line}\r\n")
  headers.each do |key, value|
    socket.print("#{key}: #{value}\r\n")
  end
  socket.print("\r\n")
  body.each do |part|
    socket.print("#{part}\r\n")
  end
  socket.close
end
