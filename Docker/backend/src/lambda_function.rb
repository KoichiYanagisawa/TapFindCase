require 'bundler/setup'
require 'rack'
require 'rack/handler/puma'
require 'puma'
require 'json'
require 'base64'
require './config/environment.rb'

# 全てのネストしたハッシュに対してキーをシンボル化する関数
def deep_symbolize_keys(obj)
  return obj.map{ |v| deep_symbolize_keys(v) } if obj.is_a? Array
  return obj unless obj.is_a? Hash

  obj.each_with_object({}) do |(k, v), result|
    result[k.to_sym] = deep_symbolize_keys(v)
  end
end

def lambda_handler(event:, context:)
  begin
    app = Rails.application
    headers = event['headers'].map { |k, v| ['HTTP_' + k.upcase.gsub('-', '_'), v] }.to_h
    body = event['body'].is_a?(String) ? event['body'] : event['body'].to_json
    query_params = deep_symbolize_keys(event['queryStringParameters'])
    query_string = query_params.nil? ? '' : query_params.map{ |k, v| "#{k}=#{v.is_a?(String) && v.match(/^(\{|\[).*(\}|\])$/) ? v : v.to_json}" }.join("&")

    env = {
      'rack.version' => Rack::VERSION,
      'rack.input' => StringIO.new(body),
      'rack.errors' => $stderr,
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,
      'rack.url_scheme' => 'http',
      'REQUEST_METHOD' => event['httpMethod'],
      'QUERY_STRING' => query_string,
      'SERVER_NAME' => 'localhost',
      'SERVER_PORT' => '80',
      'PATH_INFO' => event['path'] || '/',
      'rack.session' => {},
      'rack.session.options' => { :expire_after => 2592000 },
      'rack.request.query_string' => query_string,
      'rack.request.query_hash' => query_params
    }

    env.merge!(headers)

    status, headers, body = app.call(env)

    # Remove headers not supported by API Gateway
    %w[status connection server x-runtime x-powered-by].each do |header|
      headers.delete(header)
    end
    {
      statusCode: status,
      headers: headers.merge({
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS'
      }),
      body: body.join
    }
  rescue => e
    $stderr.puts "lambda_function内のエラー: #{e.message}"
    $stderr.puts "バックトレース:"
    $stderr.puts e.backtrace
    {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
      },
      body: { error: "Internal Server Error" }.to_json
    }
  end
end
