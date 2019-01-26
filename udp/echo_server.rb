require "socket"
require "byebug"
# start a socket on udp stream port/ip

# read at most 1024 bytes
BUFFER_SIZE = 1024

# create UDP socket
socket = Socket.new(Socket::AF_INET6, Socket::SOCK_DGRAM)
# identify port and host as an AF_INET/AF_INET6 port and host address in an Addrinfo object
sock_addr = Addrinfo.getaddrinfo("localhost", 2000)[0]
# associate socket with port and host
socket.bind(sock_addr)

# listen indefinitely
loop {
  # receive incoming message
  message, sender_info = socket.recvfrom(BUFFER_SIZE)

  # echo back
  socket.send(message.upcase, 0, sender_info)
}
