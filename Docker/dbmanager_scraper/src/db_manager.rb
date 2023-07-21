# frozen_string_literal: true

require 'dotenv/load'
require 'aws-sdk-s3'
require 'aws-sdk-dynamodb'
require 'json'

class DbManager
  def initialize
    @MAX_RETRY_COUNT = 3
    @s3 = Aws::S3::Resource.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
    @bucket = @s3.bucket(ENV['AWS_S3_BUCKET_NAME'])
    @dynamodb = Aws::DynamoDB::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  end

  def store_data_to_s3
    s3_client = Aws::S3::Client.new
    @bucket.objects(prefix: 'store_data_to_db/').each do |obj_summary|
      retry_count = 0
      puts "処理中のオブジェクト: #{obj_summary.key}"

      obj = @bucket.object(obj_summary.key)
      resp = s3_client.get_object_tagging({
        bucket: @bucket.name,
        key: obj.key
      })
      next if resp.tag_set.any? { |tag| tag.key == 'processing' && tag.value == 'true' }

      resp.tag_set << { key: 'processing', value: 'true' }
      s3_client.put_object_tagging({
        bucket: @bucket.name,
        key: obj.key,
        tagging: { tag_set: resp.tag_set }
      })

      item_infos = JSON.parse(obj.get.body.read, symbolize_names: true)
      item_infos.each do |item_info|
        begin
          update_or_create_products(item_info)
        rescue => e
          if retry_count < @MAX_RETRY_COUNT
            retry_count += 1
            puts "Error occurred, retrying... (#{retry_count}/#{@MAX_RETRY_COUNT})"
            retry
          else
            puts "DBへのデータ保存中にエラーが発生しました。このデータはスキップします Error message: #{e.message}"
            puts e.backtrace.join("\n")
            break
          end
        end
      end

      obj.delete if retry_count < @MAX_RETRY_COUNT
    end
  end

  def update_or_create_products(item_info)
    item_info[:models].each do |model|
      pk = "PRODUCT##{item_info[:ec_site_url]}##{model}"
      sk = "DETAILS"

      @dynamodb.update_item({
        table_name: "TapFindCase",
        key: {
          "PK": pk,
          "SK": sk
        },
        update_expression: "SET #name = if_not_exists(#name, :name), #maker = if_not_exists(#maker, :maker), #color = if_not_exists(#color, :color), #price = :price, #ec_site_url = :ec_site_url, #checked_at = :checked_at, #model = :model, #image_urls = :image_urls, #thumbnail_urls = :thumbnail_urls",
        expression_attribute_names: {
          "#name": "name",
          "#maker": "maker",
          "#color": "color",
          "#price": "price",
          "#ec_site_url": "ec_site_url",
          "#checked_at": "checked_at",
          "#model": "model",
          "#image_urls": "image_urls",
          "#thumbnail_urls": "thumbnail_urls"
        },
        expression_attribute_values: {
          ":name": item_info[:name],
          ":maker": item_info[:maker],
          ":color": item_info[:color],
          ":price": item_info[:price].to_s,
          ":ec_site_url": item_info[:ec_site_url],
          ":checked_at": Time.now.iso8601,
          ":model": model,
          ":image_urls": item_info[:image_url],
          ":thumbnail_urls": item_info[:thumbnail_url]
        },
        return_values_on_condition_check_failure: "ALL_OLD"
      })
    end
    puts "Successfully saved data to DynamoDB for item: #{item_info[:name]}"
  end
end
