require "socket"

# simple app interface
class FooApp
  def self.call(env)
    path = env[:path]
    # from current directory
    file_path = "#{Dir.pwd}#{path}.html"

    if File.exists?(file_path)
      body = [ File.read(file_path) ]
      status = 200
      headers = {
        "Content-Type" => "text/html"
      }
    else # 404
      body = [ "Sorry, no content found" ]
      status = 404
      headers = {
        "Content-Type" => "text/plain"
      }
    end

    [status, headers, body]
  end
end

server = TCPServer.new("localhost", "2000")

while session = server.accept
  request = session.gets
  puts request

  path = request.split(" ")[1]
  # 1
  status, headers, body = FooApp.call({
    path: path
  })

  ### Construct HTTP lines with \r\n to match accordance of HTTP standards

  # 2
  session.print "HTTP/1.1 #{status}\r\n"

  # 3
  headers.each do |key, value|
    session.print "#{key}: #{value}\r\n"
  end

  # 4
  session.print "\r\n"

  # 5
  body.each do |part|
    session.print part
  end

  session.close
end
