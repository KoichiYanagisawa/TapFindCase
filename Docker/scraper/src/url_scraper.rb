# frozen_string_literal: true

require 'set'

class URLScraper

attr_reader :urls

  def initialize
    @urls = Set.new
  end

  def search_item(wait, driver, url)
    retry_count = 0
    begin
      puts "今から商品詳細ページのURLを取得します。リトライ回数は#{retry_count}回目です。"
      driver.get(url)
      loop do
        sleep(3)
        get_urls(wait, driver, '//a[@class="ckitanker"]')
        break unless go_to_next_page(wait, driver)

        retry_count = 0
      end
    rescue StandardError => e
      puts "search_item: #{e.message}"
      retry_count += 1
      retry if retry_count <= 3
      puts '検索が3回失敗しました'
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
end
