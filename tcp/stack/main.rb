require "./tcp_client"

### Need to run with sudo to get network permission ###

# establish tcp client
tcp_client = TCPClient.new(url: "http://www.google.com")
# establish connection
tcp_client.connect
# send http GET request
tcp_client.get_page
# read data from buffer
data = tcp_client.recv(10_000)
# output to user
puts data
# close connection
tcp_client.close
