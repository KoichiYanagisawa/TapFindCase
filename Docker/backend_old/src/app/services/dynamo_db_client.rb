require 'aws-sdk-dynamodb'

class DynamoDbClient
  def self.new
    Aws::DynamoDB::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  end
end
