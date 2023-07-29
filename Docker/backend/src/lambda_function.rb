def lambda_handler(event:)
  env = build_environment(event)
  status, headers, body = call_rails_app(env)
  format_response(status, headers, body)
rescue StandardError => e
  handle_error(e)
end

def build_environment(event)
  headers = event['headers'].transform_keys { |k| "HTTP_#{k.upcase.tr('-', '_')}" }
  body = event['body'].is_a?(String) ? event['body'] : event['body'].to_json
  query_params = deep_symbolize_keys(event['queryStringParameters'])
  query_string = build_query_string(query_params)

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
    'rack.session.options' => { expire_after: 2592000 },
    'rack.request.query_string' => query_string,
    'rack.request.query_hash' => query_params
  }

  env.merge!(headers)
  env
end

def build_query_string(query_params)
  return '' if query_params.nil?

  query_params.map { |k, v| "#{k}=#{v.is_a?(String) && v.match(/^(\{|\[).*(\}|\])$/) ? v : v.to_json}" }.join('&')
end

def call_rails_app(env)
  status, headers, body = Rails.application.call(env)

  # Remove headers not supported by API Gateway
  %w[status connection server x-runtime x-powered-by].each do |header|
    headers.delete(header)
  end

  [status, headers, body]
end

def format_response(status, headers, body)
  {
    statusCode: status,
    headers: headers.merge({
                             'Access-Control-Allow-Origin' => '*',
                             'Access-Control-Allow-Headers': 'Content-Type',
                             'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS'
                           }),
    body: body.join
  }
end

def handle_error(handle_error)
  warn "lambda_function内のエラー: #{handle_error.message}"
  warn 'バックトレース:'
  warn handle_error.backtrace
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
