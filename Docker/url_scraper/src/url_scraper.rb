# frozen_string_literal: true

require 'set'
require 'tempfile'
require 'aws-sdk-s3'
require 'dotenv/load'

class URLScraper

attr_reader :urls

  def initialize
    @urls = Set.new
    @s3 = Aws::S3::Resource.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
    @bucket = @s3.bucket(ENV['AWS_S3_BUCKET_NAME'])
  end

  def search_item(wait, driver, url)
    retry_count = 0
    begin
      puts "今から商品詳細ページのURLを取得します。リトライ回数は#{retry_count}回目です。"
      driver.navigate.to(url)
      loop do
        sleep(1)
        get_urls(wait, driver, '//a[@class="ckitanker"]')
        if @urls.size >= 40
          upload_to_s3
          @urls.clear
        end
        break unless go_to_next_page(wait, driver)

        retry_count = 0
      end
    rescue StandardError => e
      puts "search_item: #{e.message}"
      retry_count += 1
      retry if retry_count <= 3
      puts '検索が3回失敗しました'
    end

    if @urls.any?
      upload_to_s3
      @urls.clear
    end
  end

  def get_urls(wait, driver, xpath)
    elements = wait.until { driver.find_elements(:xpath, xpath) }
    elements.each do |element|
      @urls.add(element.attribute('href'))
    end
    puts "現在のURL取得数:#{@urls.size}"
  rescue Selenium::WebDriver::Error::TimeoutError => e
    puts "get_urls: #{e.message}"
  end

  def go_to_next_page(wait, driver)
    next_page_element = wait.until { driver.find_element(:xpath, '//a/img[@class="pageNextOn"]') }
    next_page_element.click
  rescue Selenium::WebDriver::Error::TimeoutError
    puts 'go_to_next_page:次のページが見つかりませんでした'
    false
  else
    true
  end

  def upload_to_s3
    time_stamp = Time.now.strftime('%Y%m%d%H%M%S')
    file_name = "products_detail_urls/#{time_stamp}.txt"
    Tempfile.open(file_name) do |f|
      @urls.each { |url| f.puts(url) }
      f.rewind
      obj = @bucket.object(file_name)
      obj.upload_file(f.path)
    end
    puts "#{file_name}をS3にアップロードしました。"
  end
end
