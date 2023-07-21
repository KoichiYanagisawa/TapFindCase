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
        '#n' => 'name',
      },
      expression_attribute_values: {
        ":name" => name,
        ":SK" => 'DETAILS'
      }
      })
    response.items.first
  end

  # def put_item(item_info)
  #   item_info[:models].each do |model|
  #     pk = "PRODUCT##{item_info[:ec_site_url]}##{model}"
  #     sk = 'DETAILS'
  #     @dynamodb.put_item({
  #       table_name: 'TapFindCase',
  #       item: {
  #         "PK": pk,
  #         "SK": sk,
  #         "name": item_info[:name],
  #         "maker": item_info[:maker],
  #         "color": item_info[:color],
  #         "price": item_info[:price],
  #         "ec_site_url": item_info[:ec_site_url],
  #         "checked_at": Time.now.iso8601,
  #         "model": model,
  #         "image_urls": item_info[:image_url],
  #         "thumbnail_urls": item_info[:thumbnail_url]
  #       }
  #     })
  #   end
  # end

  # def get_item(pk, sk)
  #   @dynamodb.get_item({
  #     table_name: 'TapFindCase',
  #     key: {
  #       "PK": pk,
  #       "SK": sk
  #     }
  #   }).item
  # end

  # def update_item(item_info)
  #   item_info[:models].each do |model|
  #     pk = "PRODUCT##{item_info[:ec_site_url]}##{model}"
  #     sk = 'DETAILS'
  #     @dynamodb.update_item({
  #       table_name: 'TapFindCase',
  #       key: {
  #         "PK": pk,
  #         "SK": sk
  #       },
  #       update_expression: 'SET #name = :name, #maker = :maker, #color = :color, #price = :price, #ec_site_url = :ec_site_url, #checked_at = :checked_at, #model = :model, #image_urls = :image_urls, #thumbnail_urls = :thumbnail_urls',
  #       expression_attribute_names: {
  #         "#name": 'name',
  #         "#maker": 'maker',
  #         "#color": 'color',
  #         "#price": 'price',
  #         "#ec_site_url": 'ec_site_url',
  #         "#checked_at": 'checked_at',
  #         "#model": 'model',
  #         "#image_urls": 'image_urls',
  #         "#thumbnail_urls": 'thumbnail_urls'
  #       },
  #       expression_attribute_values: {
  #         ":name": item_info[:name],
  #         ":maker": item_info[:maker],
  #         ":color": item_info[:color],
  #         ":price": item_info[:price].to_s,
  #         ":ec_site_url": item_info[:ec_site_url],
  #         ":checked_at": Time.now.iso8601,
  #         ":model": model,
  #         ":image_urls": item_info[:image_url],
  #         ":thumbnail_urls": item_info[:thumbnail_url]
  #       }
  #     })
  #   end
  # end

  # def delete_item(pk, sk)
  #   @dynamodb.delete_item({
  #     table_name: 'TapFindCase',
  #     key: {
  #       "PK": pk,
  #       "SK": sk
  #     }
  #   })
  # end

  def self.all_unique_models
    dynamodb.scan(table_name: 'TapFindCase').items.map { |item| item['model'] }.uniq.compact.map { |model| { model: model } }
  end

  def self.find_by(field, value, index, sk, last_evaluated_key = nil, limit = 20)
    options = {
      table_name: 'TapFindCase',
      index_name: index,
      key_condition_expression: "#{field} = :val",
      filter_expression: 'SK = :SK',
      expression_attribute_values: {
        ":SK" => sk,
        ":val" => value
      },
      limit: limit
    }
    options[:exclusive_start_key] = last_evaluated_key if last_evaluated_key
    response = dynamodb.query(options)

    sorted_response = response.items.sort_by { |product| product["name"] }

    { products: sorted_response, last_evaluated_key: response.last_evaluated_key }
  end

  # # 商品のIDを指定して、その商品に対応する画像を取得するためのヘルパーメソッド
  # def self.get_images_for_product(product_id)
  #   dynamodb.get_item(
  #     table_name: 'TapFindCase',
  #     key: { 'product_id' => product_id }
  #   ).item
  # end
end
