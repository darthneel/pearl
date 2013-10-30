require 'socket'
require './request'
require 'pry'

class Server

  attr_reader :port

  def initialize(port = nil)
    @port = port || 2000
  end

  def listen
    server = TCPServer.open(port)
    loop do
      client = server.accept
      plain_request, line = '', ''
      while (line != "\x00\n")
        line = client.gets
        plain_request += line
      end
      request = Request.parse(plain_request)
      response = route request
      client.puts response.to_s
      client.close
    end
  end

  def route(request)
    case request.headers['Method']
    when 'GET' then list_messages
    when 'POST' then create_message(request.body)
    end
  end

  def messages
    @messages ||= []
  end

  def list_messages
    Request.new.tap do |request|
      request.headers = {'Status' => 200}
      request.body = messages.join
    end
  end

  def create_message(message)
    messages << message
    Request.new.tap do |request|
      request.headers = {'Status' => 201}
      request.body = ''
    end
  end
end

Server.new.listen
