require "socket"

HOST = "localhost"
PORT = "2000"

# create new server socket bound to localhost:2000
server = TCPServer.new(HOST, PORT)

# keep server open indefinitely to listen to requests
while session = server.accept
  # get client request message
  request = session.gets
  puts request

  # construct response message
  msg = <<~MSG
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    \r
    <p>Foobar is sweet!</p>
  MSG
  # send response data back
  session.print(msg)
  session.close
end
