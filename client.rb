require 'socket'
require './request'
require 'pry'

class Client

  attr_reader :hostname, :port

  def initialize(hostname, port)
    @hostname = hostname
    @port = port
  end

  def prompt
    loop { parse gets }
  end

  def list_messages_request
    Request.new.tap do |request|
      request.headers = {
        'Method' => 'GET',
        'Date' => Time.now.strftime('%Y-%m-%d %H:%M')
      }
      request.body = ''
    end
  end

  def send_request(request)
    server = TCPSocket.open(hostname, port)
    server.puts request.to_s
    response = []
    while (line = server.gets)
      response << line
    end
    response = Request.parse(response.join "\n")
    puts response.body
    server.close
  end

  def parse(input)
    if input.match(/^GET\n$/)
      request = list_messages_request
      send_request(request)
    else
      request = new_message_request with: input
      send_request(request)
    end
  end

  def list_messages(options) # GET
    Request.new.tap do |request|
      request.headers = { 'Method' => 'GET' }
    end
  end

  def new_message_request(options)
    Request.new.tap do |request|
      request.headers = {
        'Method' => 'POST',
        'Date' => Time.now.strftime('%Y-%m-%d %H:%M')
      }
      request.body = options[:with]
    end
  end
end

Client.new('localhost', 2000).prompt
