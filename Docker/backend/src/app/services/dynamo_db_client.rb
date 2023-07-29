require 'aws-sdk-dynamodb'

class DynamoDbClient
  def self.new
    Aws::DynamoDB::Client.new(
      region: ENV.fetch('MY_AWS_REGION', nil),
      access_key_id: ENV.fetch('MY_AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('MY_AWS_SECRET_ACCESS_KEY', nil)
    )
  end
end
