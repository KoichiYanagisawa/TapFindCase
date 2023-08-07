# frozen_string_literal: true

require 'aws-sdk-s3'
require 'dotenv/load'
require 'aws-sdk-secretsmanager'

require_relative './image_scraper'

class InfoScraper
  MAX_THREADS = 3

  def initialize(user_agents: nil, options: nil, wait: nil)
    @user_agents = user_agents
    @options = options
    @wait = wait

    @image_scraper = ImageScraper.new
    setup_s3

    @mutex = Mutex.new
  end

  def setup_s3
    s3_options = {
      region: ENV['MY_AWS_REGION'],
      access_key_id: ENV['MY_AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['MY_AWS_SECRET_ACCESS_KEY']
    }
    @s3 = Aws::S3::Resource.new(s3_options)
    @s3_client = Aws::S3::Client.new(s3_options)
    @bucket = @s3.bucket(ENV['BACKEND_AWS_S3_BUCKET'])
  end


  def setup_new_driver
    driver = Selenium::WebDriver.for :chrome, options: @options
    driver.manage.timeouts.implicit_wait = 20
    driver.manage.timeouts.page_load = 20
    driver
  end

  def get_item_info
    @bucket.objects(prefix: 'products_detail_urls/').each do |obj_summary|
      obj = @bucket.object(obj_summary.key)
      process_s3_object(obj)
    end
  end

  def process_s3_object(obj)
    resp = get_object_tags(obj)

    return if resp.tag_set.any? { |tag| tag.key == 'processing' && tag.value == 'true' }
    update_object_tag(obj, resp.tag_set)

    urls = get_urls_from_s3(obj)
    item_infos = process_urls(urls)
    obj.delete
    save_item_infos_to_s3(obj.key, item_infos)
  end

  def get_object_tags(obj)
    @s3_client.get_object_tagging({
      bucket: ENV['BACKEND_AWS_S3_BUCKET'],
      key: obj.key
    })
  end

  def update_object_tag(obj, existing_tags)
    new_tags = existing_tags << { key: 'processing', value: 'true' }
    @s3_client.put_object_tagging({
      bucket: ENV['BACKEND_AWS_S3_BUCKET'],
      key: obj.key,
      tagging: {
        tag_set: new_tags
      }
    })
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

  def process_urls(urls)
    item_infos = []
    threads = []
    urls.each_with_index do |url, index|
      manage_threads(threads)
      threads << Thread.new do
        process_url_in_thread(url, item_infos)
      end
      puts "Processing URL #{index + 1} out of #{urls.count}"
    end
    threads.each(&:join)
    item_infos
  end

  def manage_threads(threads)
    while threads.size >= MAX_THREADS
      threads.delete_if { |t| !t.status }
      sleep(0.5)
    end
    sleep(1)
  end

  def process_url_in_thread(url, item_infos)
    local_wait = @wait
    local_driver = setup_new_driver
    item_info = process_url(url, local_wait, local_driver)

    @mutex.synchronize do
      item_infos << item_info
    end

    local_driver.quit
  end

  def process_url(url, wait, driver)
    item_info = nil
    retry_on_error do
      driver.navigate.to(url)
      sleep(1)
      item_info = extract_item_info(wait, driver)
      item_info[:models] = extract_models(wait, driver)
      item_info[:image_url], item_info[:thumbnail_url] = @image_scraper.get_item_images(wait, driver,
                                                                                            driver.current_url)
    end
    item_info
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
