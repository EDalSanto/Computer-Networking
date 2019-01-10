require "byebug"
require "uri"
require "cgi"

class App
  # map extensions to content types
  CONTENT_TYPE_MAPPING = {
    "html" => "text/html",
    "txt"  => "text/plain",
    "png"  => "image/png",
    "jpg"  => "image/jpg"
  }

  # treat as binary data if file type cannot be found
  DEFAULT_CONTENT_TYPE = "application/octet-stream"

  # define where assets to serve will be loaded from
  WEB_ROOT = "./public"

  # entry point to app
  def self.call(env)
    case env["REQUEST_METHOD"]
    when "POST" # write to file
      # get data body
      data = env["DATA"]
      # write to file
      File.open("foo.db", "a") do |f|
        id = File.readlines("foo.db").length + 1
        f.puts "id=#{id}, #{data}"
      end
      # handle success message
      status_line = "HTTP/1.1 201 CREATED"
      # always return location of new resource whether 201 or 302 redirect
      headers = ["Location" => "./foo.db" ]
      # return representation of object created
      object = File.readlines("foo.db").last
      body = [object]
    when "GET", "HEAD"
      full_path = requested_file(env["PATH_INFO"])
      file = existing_file_at(full_path)

      if file
        # response line
        status_line = "HTTP/1.1 200 OK"
        # headers
        headers = {
          "Content-Type": "#{content_type(file)}",
          "Content-Length": "#{file.size} bytes",
          "Connection": "close"
        }
        body = (env["REQUEST_METHOD"] == "GET") ? [File.read(file)] : []
      else # file not found
        response = "File not found\n"
        # write response line
        status_line = "HTTP/1.1 404 File Not Found"
        # write headers
        headers = {
          "Content-Type": "text/plain",
          "Content-Length": "#{response.size} bytes",
          "Connection": "close"
        }
        # write the contents of the file to the socket
        body = (env["REQUEST_METHOD"] == "GET") ? [response] : []
        p body
      end
    end
    [ status_line, headers, body ]
  end

  private

  # helper function to parse extension of requested file
  # returns content type
  def self.content_type(path)
    ext = File.extname(path).split(".").last
    CONTENT_TYPE_MAPPING[ext]
  end

  # takes a request line (i.e., GET /path?foo=bar HTTP/1.1)
  # and extracts the path from it, scrubbing out parameters
  # and unescaping URI encoding
  #
  # this path (i.e, /path) is then converted to relative path
  # from web applications root
  #
  # while relatively trivial to implement simple implementation
  # has major security vulnerabilty is potentially allowing
  # requesting user access to any file on server file system
  def self.requested_file(uri)
    path = CGI.unescape(URI(uri).path)

    # making use of Rack::File implementation since notoriusly hard to implement
    clean = []
    # split the path into component parts
    parts = path.split("/")

    parts.each do |part|
      # skip any empty or current directory path components
      next if part.empty? || part == "."
      # If the path goes up one directory level, remove last component from clean components
      # else add to public
      part == ".." ? clean.pop : clean.push(part)
    end

    File.join(WEB_ROOT, *clean)
  end

  def self.existing_file_at(path)
    # check that exists with one of file extensions
    CONTENT_TYPE_MAPPING.keys.find do |content_type|
      full_path = "#{path}.#{content_type}"

      return full_path if File.exists?(full_path) && !File.directory?(full_path)
    end
  end
end
