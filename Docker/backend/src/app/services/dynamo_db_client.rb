require 'aws-sdk-dynamodb'

class DynamoDbClient
  def self.new
    Aws::DynamoDB::Client.new(
      region: ENV.fetch('MY_AWS_REGION', nil),
      access_key_id: ENV.fetch('MY_AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('MY_AWS_SECRET_ACCESS_KEY', nil)
    )
  end

  def get_item(options)
    self.class.new.get_item(options)
  end

  def put_item(options)
    self.class.new.put_item(options)
  end

  def update_item(options)
    self.class.new.update_item(options)
  end

  def query(options)
    self.class.new.query(options)
  end

  def batch_write_item(options)
    self.class.new.batch_write_item(options)
  end

  def batch_get_item(options)
    self.class.new.batch_get_item(options)
  end

  def delete_item(options)
    self.class.new.delete_item(options)
  end

  def scan(options)
    self.class.new.scan(options)
  end
end
