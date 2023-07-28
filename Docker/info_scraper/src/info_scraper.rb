# frozen_string_literal: true

require 'aws-sdk-s3'
require 'dotenv/load'
require 'aws-sdk-secretsmanager'

require_relative './image_scraper'

class InfoScraper
  def initialize
    @image_scraper = ImageScraper.new
    @s3 = Aws::S3::Resource.new(
      region: ENV['MY_AWS_REGION'],
      access_key_id: ENV['MY_AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['MY_AWS_SECRET_ACCESS_KEY']
    )
    @bucket = @s3.bucket(ENV['BACKEND_AWS_S3_BUCKET'])
  end

  def get_item_info(wait, driver)
    s3_client = Aws::S3::Client.new(
      region: ENV['MY_AWS_REGION'],
      access_key_id: ENV['MY_AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['MY_AWS_SECRET_ACCESS_KEY']
    )

    @bucket.objects(prefix: 'products_detail_urls/').each do |obj_summary|
      obj = @bucket.object(obj_summary.key)

      # タグを取得
      resp = s3_client.get_object_tagging({
                                            bucket: @bucket.name,
                                            key: obj.key
                                          })
      next if resp.tag_set.any? { |tag| tag.key == 'processing' && tag.value == 'true' }

      # タグを設定
      resp.tag_set << { key: 'processing', value: 'true' }
      s3_client.put_object_tagging({
                                     bucket: @bucket.name,
                                     key: obj.key,
                                     tagging: { tag_set: resp.tag_set }
                                   })

      item_infos = []
      urls = get_urls_from_s3(obj)
      urls.each_with_index do |url, index|
        retry_on_error do
          puts "現在の処理: #{index + 1}/#{urls.length}"
          driver.navigate.to(url)
          sleep(1)
          item_info = extract_item_info(wait, driver)
          item_info[:models] = extract_models(wait, driver)
          item_info[:image_url], item_info[:thumbnail_url] = @image_scraper.get_item_images(wait, driver,
                                                                                            driver.current_url)
          item_infos << item_info
        end
      end
      obj.delete
      save_item_infos_to_s3(obj.key, item_infos)
    end
  end

  def get_urls_from_s3(s3_object)
    urls = []
    s3_object.get.body.read.split("\n").each do |url|
      urls << url
    end
    urls
  end

  def save_item_infos_to_s3(object_key, item_infos)
    file_name = object_key.split('/').last
    @bucket.object("store_data_to_db/#{file_name}").put(body: JSON.generate(item_infos))
  end

  def extract_item_info(wait, driver)
    item_info = {}
    raw_name = wait.until { driver.find_element(:xpath, '//div[@id="titleBox"]/div[1]/h2[@itemprop="name"]').text }
    name, color = split_name_and_color(raw_name)
    item_info[:name] = name.gsub('/', '-')
    item_info[:color] = color
    item_info[:maker] = wait.until { driver.find_element(:xpath, '//*[@id="relateList"]/li/a').text }
    item_info[:ec_site_url] = decode_url(wait.until do
                                           driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/div[3]/span/a').attribute('href')
                                         end)
    item_info[:price] = wait.until do
      driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/p/span[@class="priceTxt"]').text
    end
    item_info
  end

  def split_name_and_color(item_name)
    color = item_name.match(/\[(.*?)\]/)
    name = item_name.gsub(/\[(.*?)\]/, '').strip
    color = color[1] if color
    [name, color]
  end

  def decode_url(url)
    uri = URI.parse(url)
    params = CGI.parse(uri.query)
    URI.decode_www_form_component(params['Url'][0])
  end

  def extract_models(wait, driver)
    model_info_text = wait.until { driver.find_element(:xpath, '//div[@id="specBox"]/p').text }
    models = model_info_text.match(/対応機種：(iPhone .+)/)[1].split(%r{/|\s/\s})
    models.map do |model|
      model = model.gsub(/(\s第)(\d+)(世代)/, '(第\2世代)')
      model = model.gsub(/SE2/, 'SE(第2世代)')  # SE2 を SE(第2世代) に変換
      model = model.gsub(/SE3/, 'SE(第3世代)')  # SE3 を SE(第3世代) に変換
      model = "iPhone #{model}" unless model.include?('iPhone')
      model.strip
    end
  end

  def retry_on_error
    retry_count = 0
    begin
      yield
    rescue StandardError => e
      puts "InfoScraper: #{e.message}"
      retry_count += 1
      retry if retry_count <= 3
      puts 'リトライが3回失敗しました'
    end
  end
end
