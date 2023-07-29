require 'bundler/setup'
require 'rack'
require 'rack/handler/puma'
require 'puma'
require 'json'
require 'base64'
require './config/environment'

# 全てのネストしたハッシュに対してキーをシンボル化する関数
def deep_symbolize_keys(obj)
  return obj.map{ |v| deep_symbolize_keys(v) } if obj.is_a? Array
  return obj unless obj.is_a? Hash

  obj.each_with_object({}) do |(k, v), result|
    result[k.to_sym] = deep_symbolize_keys(v)
  end
end

def build_query_string(query_params)
  return '' if query_params.nil?

  query_params.map{ |k, v| "#{k}=#{v.is_a?(String) && v.match(/^(\{|\[).*(\}|\])$/) ? v : v.to_json}" }.join('&')
end

def build_env(event, headers, body, query_string, query_params)
  {
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
    'rack.session.options' => { expire_after: 2592000 },
    'rack.request.query_string' => query_string,
    'rack.request.query_hash' => query_params
  }.merge(headers)
end

def remove_unsupported_headers(headers)
  %w[status connection server x-runtime x-powered-by].each do |header|
    headers.delete(header)
  end
  headers
end

def lambda_handler(event:, _context:)
  app = Rails.application
  headers = event['headers'].transform_keys { |k| "HTTP_#{k.upcase.tr('-', '_')}" }
  body = event['body'].is_a?(String) ? event['body'] : event['body'].to_json
  query_params = deep_symbolize_keys(event['queryStringParameters'])
  query_string = build_query_string(query_params)

  env = build_env(event, headers, body, query_string, query_params)

  status, headers, body = app.call(env)

  headers = remove_unsupported_headers(headers)

  {
    statusCode: status,
    headers: headers.merge({
                             'Access-Control-Allow-Origin' => '*',
                             'Access-Control-Allow-Headers': 'Content-Type',
                             'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS'
                           }),
    body: body.join
  }
rescue StandardError => e
  warn "lambda_function内のエラー: #{e.message}"
  warn 'バックトレース:'
  warn e.backtrace
  {
    statusCode: 500,
    headers: {
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    },
    body: { error: 'Internal Server Error' }.to_json
  }
end
