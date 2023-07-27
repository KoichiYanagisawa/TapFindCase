# frozen_string_literal: true

require 'dotenv/load'
require 'aws-sdk-s3'
require 'net/http'

class ImageScraper
  def get_item_images(wait, driver, url)
    puts "商品画像を取得します: #{url}"

    retry_on_error do
      item_id = get_item_id(url)
      image_list_url = generate_image_list_url(item_id)

      driver.navigate.to(image_list_url)
      sleep(1)

      thumbnail_elements = get_thumbnail_elements(wait, driver)
      thumbnail_file_paths = []
      image_file_paths = []

      thumbnail_elements.each_with_index do |thumbnail_element, i|
        thumbnail_url = thumbnail_element.attribute('src')
        thumbnail_file_path = save_image(thumbnail_url, "#{item_id}_thumbnail_#{i}", true)
        thumbnail_file_paths << thumbnail_file_path

        thumbnail_element.click
        sleep(3)

        image_url = get_large_image_url(wait, driver)
        image_file_path = save_image(image_url, "#{item_id}_large_#{i}")
        image_file_paths << image_file_path
      end

      [image_file_paths, thumbnail_file_paths]
    end
  end

  def get_item_id(url)
    url.match(%r{https://kakaku\.com/item/(K\d+)/})[1]
  end

  def generate_image_list_url(item_id)
    "https://kakaku.com/item/#{item_id}/images/"
  end

  def get_thumbnail_elements(wait, driver)
    wait.until { driver.find_elements(:xpath, '//div[@class="zoomimgList"]//img') }
  end

  def get_large_image_url(wait, driver)
    wait.until { driver.find_element(:xpath, '//img[@class="zoomimg"]').attribute('src') }
  end

  def save_image(image_url, filename, is_thumbnail = false)
    s3 = Aws::S3::Resource.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
    bucket_name = ENV['AWS_S3_BUCKET_NAME']
    bucket = s3.bucket(bucket_name)
    uri = URI(image_url)
    object_key = nil

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        if response.is_a?(Net::HTTPSuccess)
          object_key = is_thumbnail ? "thumbnails/#{filename}.jpg" : "images/#{filename}.jpg"
          bucket.put_object(key: object_key, body: response.body)
          puts object_key
        else
          puts "Failed to download the image: #{response}"
        end
      end
    end
    object_key
  end

  def retry_on_error
    retry_count = 0
    begin
      yield
    rescue StandardError => e
      puts "ImageScraper: #{e.message}"
      retry_count += 1
      retry if retry_count <= 3
      puts 'リトライが3回失敗しました'
    end
  end
end
