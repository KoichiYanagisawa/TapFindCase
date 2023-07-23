require 'bundler/setup'
require 'rack'
require 'rack/handler/puma'
require 'puma'
require 'json'
require 'base64'
require './config/environment.rb'

def lambda_handler(event:, context:)
  # app = Rack::Builder.new do
  #   map "/" do
  #     run Rails.application
  #   end
  # end
  app = Rails.application

  body = event['body'] ? Base64.decode64(event['body']) : ''
  headers = event['headers'].map { |k, v| ['HTTP_' + k.upcase.gsub('-', '_'), v] }.to_h

  env = {
    'rack.version' => Rack::VERSION,
    'rack.input' => StringIO.new(body),
    'rack.errors' => $stderr,
    'rack.multithread' => false,
    'rack.multiprocess' => false,
    'rack.run_once' => false,
    'rack.url_scheme' => 'http',
    'REQUEST_METHOD' => event['httpMethod'],
    'QUERY_STRING' => event['queryStringParameters'].nil? ? '' : event['queryStringParameters'].map{ |k, v| "#{k}=#{v}" }.join("&"),
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => '80',
    'PATH_INFO' => event['path'] || '/',
    'rack.session' => {},
    'rack.session.options' => { :expire_after => 2592000 },
  }

  env.merge!(headers)

  status, headers, body = app.call(env)

  # Remove headers not supported by API Gateway
  %w[status connection server x-runtime x-powered-by].each do |header|
    headers.delete(header)
  end

  {
    statusCode: status,
    headers: headers,
    body: body.join
  }
end
