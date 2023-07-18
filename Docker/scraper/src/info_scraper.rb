# frozen_string_literal: true

require_relative './db_manager'
require_relative './image_scraper'

class InfoScraper
  def initialize
    @image_scraper = ImageScraper.new
  end
  def get_item_info(wait, driver, urls)
    urls.each_with_index do |url, index|
      retry_on_error do
        puts "現在の処理: #{index + 1}/#{urls.length}"
        driver.get(url)
        sleep(3)
        item_info = extract_item_info(wait, driver)
        item_info[:models] = extract_models(wait, driver)
        item_info[:image_url], item_info[:thumbnail_url] = @image_scraper.get_item_images(wait, driver, driver.current_url)
        DbManager.store_data_to_db(item_info)
      end
    end
  end

  def extract_item_info(wait, driver)
    item_info = {}
    raw_name = wait.until { driver.find_element(:xpath, '//div[@id="titleBox"]/div[1]/h2[@itemprop="name"]').text }
    name, color = split_name_and_color(raw_name)
    item_info[:name] = name
    item_info[:color] = color
    item_info[:maker] = wait.until { driver.find_element(:xpath, '//*[@id="relateList"]/li/a').text }
    item_info[:ec_site_url] = decode_url(wait.until { driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/div[3]/span/a').attribute('href') })
    item_info[:price] = wait.until { driver.find_element(:xpath, '//*[@id="priceBox"]/div[1]/div/p/span[@class="priceTxt"]').text }
    item_info
  end

  def split_name_and_color(item_name)
    color = item_name.match(/\[(.*?)\]/)
    name = item_name.gsub(/\[(.*?)\]/, '').strip
    color = color[1] if color
    return name, color
  end

  def decode_url(url)
    uri = URI.parse(url)
    params = CGI.parse(uri.query)
    URI.decode_www_form_component(params['Url'][0])
  end

  def extract_models(wait, driver)
    model_info_text = wait.until { driver.find_element(:xpath, '//div[@id="specBox"]/p').text }
    models = model_info_text.match(/対応機種：(iPhone .+)/)[1].split(/\/|\s\/\s/)
    models.map do |model|
      model = model.gsub(/(\s第)(\d+)(世代)/, '(第\2世代)')
      model = model.gsub(/SE2/, 'SE(第2世代)')  # SE2 を SE(第2世代) に変換
      model = model.gsub(/SE3/, 'SE(第3世代)')  # SE3 を SE(第3世代) に変換
      model = "iPhone #{model}" unless model.include?("iPhone")
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
