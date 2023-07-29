require 'aws-sdk-dynamodb'

require_relative '../services/dynamo_db_client'

class Product
  def self.dynamodb
    @dynamodb ||= DynamoDbClient.new
  end

  def initialize
    @dynamodb = self.class.dynamodb
  end

  def self.find_by_name(name)
    response = dynamodb.query({
                                table_name: 'TapFindCase',
                                index_name: 'name_SK_index',
                                key_condition_expression: '#n = :name AND SK = :SK',
                                expression_attribute_names: {
                                  '#n' => 'name'
                                },
                                expression_attribute_values: {
                                  ':name' => name,
                                  ':SK' => 'DETAILS'
                                }
                              })
    response.items.first
  end

  def self.all_unique_models
    dynamodb.scan(table_name: 'TapFindCase').items.pluck('model').uniq.compact.map { |model| { model: } }
  end

  def self.find_by(field, value, index, sort_key, last_evaluated_key = nil, limit = 20)
    options = {
      table_name: 'TapFindCase',
      index_name: index,
      key_condition_expression: "#{field} = :val",
      filter_expression: 'SK = :SK',
      expression_attribute_values: {
        ':SK' => sort_key,
        ':val' => value
      },
      limit:
    }
    options[:exclusive_start_key] = last_evaluated_key if last_evaluated_key
    response = dynamodb.query(options)

    sorted_response = response.items.sort_by { |product| product['name'] }

    { products: sorted_response, last_evaluated_key: response.last_evaluated_key }
  end
end
