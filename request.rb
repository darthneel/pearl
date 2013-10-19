class Request
  REQUEST_SEPARATOR = "\n\n"
  HEADER_SEPARATOR = "\n"

  def self.parse(request)
    headers, body = request.split(REQUEST_SEPARATOR, 2)
    instance = new
    instance.headers = Request.parse_headers headers
    instance.body = body
    instance
  end

  def self.parse_headers(headers)
    split_headers = headers.split(HEADER_SEPARATOR).map do |header|
      header.split(' ', 2)
    end
    Hash[split_headers]
  end

  attr_accessor :body, :headers

  def encoded_headers
    headers.map { |k, v| "#{k} #{v}"}.join(HEADER_SEPARATOR)
  end

  def to_s
    "#{encoded_headers}#{REQUEST_SEPARATOR}#{body}"
  end
end
