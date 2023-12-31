require 'aws-sdk-dynamodb'

class User
  attr_accessor :id, :cookie_id

  def self.dynamodb
    @dynamodb ||= Aws::DynamoDB::Client.new(
      region: ENV.fetch('MY_AWS_REGION', nil),
      access_key_id: ENV.fetch('MY_AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('MY_AWS_SECRET_ACCESS_KEY', nil)
    )
    raise 'Failed to initialize DynamoDB client' unless @dynamodb

    @dynamodb
  end

  def self.table_name
    'TapFindCase'
  end

  def self.find_by(id)
    response = dynamodb.get_item({
                                   table_name:,
                                   key: {
                                     PK: id,
                                     SK: 'USER'
                                   }
                                 })
    response.item
  end

  def self.find_or_create_by_cookie_id(cookie_id)
    response = dynamodb.query({
                                table_name:,
                                index_name: 'cookie_id_index',
                                key_condition_expression: 'cookie_id = :cookie_id',
                                expression_attribute_values: { ':cookie_id' => cookie_id }
                              })

    if response.items.empty?
      new_user = { 'PK' => SecureRandom.uuid,
                   'SK' => 'USER',
                   'cookie_id' => cookie_id }
      dynamodb.put_item({
                          table_name:,
                          item: new_user
                        })
      new_user
    else
      response.items.first
    end
  end
end
