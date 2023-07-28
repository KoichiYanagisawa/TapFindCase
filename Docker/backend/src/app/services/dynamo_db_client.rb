require 'aws-sdk-dynamodb'

class DynamoDbClient
  def self.new
    Aws::DynamoDB::Client.new(
      region: ENV['MY_AWS_REGION'],
      access_key_id: ENV['MY_AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['MY_AWS_SECRET_ACCESS_KEY']
    )
  end
end
