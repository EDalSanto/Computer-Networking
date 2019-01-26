require "socket"

class Client
  # receives a server instance so it can establish connection
  def initialize(server)
    @server = server
    @request = nil
    @response = nil
    # initiate thread to listen for server
    listen
    # initiate thread to send to server
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop { # listen forever
        # listen for the server response
        msg = @server.gets.chomp
        # show them in the console
        puts "#{msg}"
      }
    end
  end

  def send
    puts "Enter the username: "
    @request = Thread.new do
      loop { # write as much as you want
        # read from the console
        msg = $stdin.gets.chomp
        # with the enter key, send the message to the server
        @server.puts(msg)
      }
    end
  end
end

# running this client program will open TCP socket as a server
# Socket::AF_INET -> socket can communicate with addresses in IPv4 family
  # AF -> address family used to identify the types of addresses socket can communicate with
  # INET -> IPv4
# Socket::SOCK_STREAM -> socket type that corresponds to TCP
server = Socket.new(Socket::AF_INET6, Socket::SOCK_STREAM)
# connect to TCP server running on localhost:3000
server.connect(Socket.pack_sockaddr_in(3000, "localhost"))
Client.new(server)
