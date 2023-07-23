class History
  def self.dynamodb
    @dynamodb ||= DynamoDbClient.new
  end

  def initialize
    @dynamodb = self.class.dynamodb
  end

  def self.create_or_update(user_id, product_name, viewed_at)
    pk = "HISTORY##{user_id}##{product_name}"
    sk = "HISTORY"
    response = dynamodb.get_item({
      table_name: 'TapFindCase',
      key: {
        'PK' => pk,
        'SK' => sk
      }
    }).item

    if response
      dynamodb.update_item({
        table_name: 'TapFindCase',
        key: {
          'PK' => pk,
          'SK' => sk
        },
        attribute_updates: {
          'viewed_at' => {
            value: viewed_at,
            action: 'PUT'
          }
        }
      })
    else
      dynamodb.put_item({
        table_name: 'TapFindCase',
        item: {
          'PK' => pk,
          'SK' => sk,
          'name' => product_name,
          'user_id' => user_id,
          'viewed_at' => viewed_at
        }
      })
    end
  end
end
