require "socket"
require "rack"
require "rack/lobster"

# Rack::Lobster will provide more dynamic means of responding to requests

app = Rack::Lobster.new
server = TCPServer.new(2000)

while session = server.accept
  request = session.gets
  puts request

  # get method, path/query params
  method, full_path = request.split(" ")
  # separate query string from path
  path, query = full_path.split("?")
  # construct app env
  env = {
    "REQUEST_METHOD" => method,
    "PATH_INFO" => path,
    "QUERY_STRING" => query
  }

  # deconstruct request
  status, headers, body = app.call(env)

  # start printing HTTP response to client
  # status line
  session.print "HTTP/1.1 #{status}\r\n"
  # headers
  headers.each do |key, value|
    session.print "#{key}: #{value}\r\n"
  end
  # space
  session.print "\r\n"
  # body
  body.each do |part|
    session.print part
  end

  session.close
end
