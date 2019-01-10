require "socket"

HOST = "localhost"
PORT = "2000"

client = TCPSocket.new(HOST, PORT)

while line = client.gets
  client.send(
  puts(line)
end

client.close
