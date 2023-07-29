require_relative '../services/dynamo_db_client'

class Favorite
  def self.dynamodb
    @dynamodb ||= DynamoDbClient.new
  end

  def initialize
    @dynamodb = self.class.dynamodb
  end

  def self.create(user_id:, product_id:)
    pk = "FAVORITE##{user_id}##{product_id}"
    sk = 'FAVORITE'
    dynamodb.put_item({
                        table_name: 'TapFindCase',
                        item: {
                          PK: pk,
                          SK: sk,
                          user_id:,
                          name: product_id,
                        }
                      })
    { 'product_id' => product_id }
  end

  def self.destroy(user_id:, product_id:)
    pk = "FAVORITE##{user_id}##{product_id}"
    sk = 'FAVORITE'
    dynamodb.delete_item({
                           table_name: 'TapFindCase',
                           key: {
                             PK: pk,
                             SK: sk,
                           }
                         })
  end

  def self.find_by(user_id:, product_id:)
    pk = "FAVORITE##{user_id}##{product_id}"
    sk = 'FAVORITE'
    response = dynamodb.get_item({
                                   table_name: 'TapFindCase',
                                   key: {
                                     PK: pk,
                                     SK: sk,
                                   }
                                 })
    response.item
  end

  def self.find_by_user_and_case(user_id:, case_name:)
    response = dynamodb.query({
                                table_name: 'TapFindCase',
                                index_name: 'user_id_index',
                                key_condition_expression: 'user_id = :user_id',
                                filter_expression: 'SK = :sk and #n = :name',
                                expression_attribute_names: {
                                  '#n' => 'name'
                                },
                                expression_attribute_values: {
                                  ':sk' => 'FAVORITE',
                                  ':user_id' => user_id,
                                  ':name' => case_name
                                }
                              })
    !response.items.empty?
  end


  def self.find_all_by_user(user_id:)
    response = dynamodb.query({
                                table_name: 'TapFindCase',
                                index_name: 'user_id_index',
                                key_condition_expression: 'user_id = :user_id',
                                filter_expression: 'SK = :sk',
                                expression_attribute_values: {
                                  ':user_id' => user_id,
                                  ':sk' => 'FAVORITE'
                                }
                              })
    response.items.pluck('name')
  end
end
